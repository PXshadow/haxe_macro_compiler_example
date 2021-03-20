import haxe.macro.Type.TypedExpr;
import haxe.macro.Context;
#if macro
function gen() {
    //Adds a callback function callback which is invoked after the compiler's typing phase, just before its generation phase.
    Context.onGenerate(types -> { //Haxe gives out typed macro exprs here
        //inits
        function stringExpr(expr:TypedExpr):String { //turn a typed expr into a string
            switch expr.expr {
                case TFunction(tfunc):
                    var str = "";
                    if (tfunc.args.length > 0) {
                        trace("unsupported arguments for a function");
                        str += "#NULL ";
                    }else{
                        str += "() ";
                    }
                    switch tfunc.t {
                        case TAbstract(t, params):
                            var t = t.get();
                            if (t.name != "Void")
                                trace("unsupport function return: " + tfunc.t);
                        default:
                            trace("unsupported function return: " + tfunc.t);
                    }
                    var block = tfunc.expr;
                    str += stringExpr(block);
                    return str;
                case TBlock(el):
                    var str = "{\n";
                    var tab = "    ";
                    str += tab + [for (expr in el) stringExpr(expr)].join(";\n");
                    return str + "\n}";
                case TCall(e, el):
                    var str = stringExpr(e) + "(";
                    str += [for (expr in el) stringExpr(expr)].join(",");
                    return str + ")";
                case TConst(c):
                    switch c {
                        case TString(s):
                            return '"$s"';
                        case TInt(i):
                            return '$i';
                        default:
                            trace("unsupported constant: " + c);
                            return "#NULL";
                    }
                case TField(e, fa):
                    return stringExpr(e);
                case TTypeExpr(m):
                    switch m {
                        case TClassDecl(c):
                            var c = c.get();
                            if (c.name == "Log" && c.pack.length == 1 && c.pack[0] == "haxe")
                                return "console.log";
                            trace("unknown class decl: " + c);
                            return "#NULL";
                        default:
                            trace("unknown type expr module type: " + m);
                            return "#NULL";
                    }
                case TObjectDecl(fields):
                    var str = "{";
                    str += [for (field in fields) field.name + " : " + stringExpr(field.expr)].join(",");
                    return str + "}";
                default:
                    trace("unknown expr: " + expr.expr);
                    return "#NULL";
            }
        }
        var content = "";
        for (type in types) {
            switch type {
                case TInst(t, params):
                    var t = t.get();
                    if (t.pack.length > 0 && t.pack[0] == "haxe")
                        continue; //don't include haxe std classes for generation
                    switch t.name {
                        case "String","Reflect","Std","Math","EReg","EnumValue_Impl_","IntIterator","ArrayAccess","StringBuf","StringTools",
                        "Sys","Type","Any_Impl_","Array":
                            continue;
                    }
                    
                    switch t.kind {
                        case KModuleFields(module):
                            var fields = t.statics.get(); //static variables and functions
                            for (field in fields) {
                                switch field.kind {
                                    case FMethod(k):
                                        switch k {
                                            case MethNormal,MethInline:
                                                content += "function " + field.name + stringExpr(field.expr());
                                            default:
                                                trace("don't know how to type field method kind: " + k);
                                        }
                                    default:
                                        trace("don't know how to type field kind: " + field.kind);
                                }
                            }
                        default:
                            trace("don't know how to type non module class kinds: " + t.kind);
                    }
                case TAbstract(t, params): //holds basic types by default such as: Void,Float,Int,Null,Bool
                case TType(t, params): //holds std types by default such as: Map,Int64,Bytes
                case TEnum(t, params): //holds std type enum by default: ValueType,haxe.StackItem,haxe.io.Encoding and haxe.io.Error
                default:
                    trace(type);
            }
        }
        //generate
        trace("generated...");
        content += "\nmain();";
        sys.io.File.saveContent("main.js",content);
        //run the js
        trace("running...");
        Sys.command("node main.js");
    });
}
#end