# Haxe macro compiler example

An example macro compiler using Haxe.

1. in the ``build.hxml`` the line ``--macro Macro.gen()`` serves as the entry point for the the initialization macro.
2. In the ``gen()`` function ``Context.onGenerate`` callback is called and retrieves the macro Types.
3. The Types are iterated through, and enum switch cased in order to distinguish the kinds.
4. Most of the generation will be done in ``stringExpr()`` as the expr will need js equivalent string representations.
5. Kinds that are not supported are logged indicating the kind name and the kind that is not supported yet, an unknown kind/type/expr is returned #NULL following Haxe's ``haxe.macro.Printer`` standard.



## Extra references

* [haxe.macro.Printer](https://github.com/HaxeFoundation/haxe/blob/4.2.1/std/haxe/macro/Printer.hx)
* [dtshx's tools.HaxeTools](https://github.com/haxiomic/dts2hx/blob/043df48e7eb037f7dd23d7ef0da7a92022f81fe3/src/tool/HaxeTools.hx)
* [hxpico8](https://github.com/YAL-Haxe/hxpico8)