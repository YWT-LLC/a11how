# A11how

## <br>Getting Started

Some helpful documentation if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab) (Flutter)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook) (Flutter)
- [Open UI: Digital accessibility made Ez](https://github.com/YWT-LLC/open_ui) (YWT)

And videos:

- [First app tutorial](https://www.youtube.com/watch?v=xWV71C2kp38) (Flutter)
- [First app code lab](https://www.youtube.com/watch?v=8sAyPDLorek) (Flutter)
- [Using external packages](https://www.youtube.com/watch?v=WdXcJdhWcEY) (Net Ninja)

### <br>From scratch

If this is one of your first coding projects, welcome! We're honored to help catalyze something new for you.

Some (free) things that will make your life easier...
1. An IDE (Integrated Development Environment). Essentially Word/Docs for coding. By default, Open UI generated apps pair well with [VS Code](https://code.visualstudio.com/download)
2. If you setup VS Code, some **extensions** (similar ones are likely available for other IDEs)
   1. `Dart`: Flutter is a Dart framework. Dart is the underlying language (like C, Python, Java, etc), while Flutter is similar to a library, but HUGE.
   2. `Flutter`: Needs no introduction
      1. `Flutter Widget Snippets` and `Awesome Flutter Snippets` provide some shortcuts while coding. More seasoned developers will get more out of them, but they also won't hinder new players.
   3. `YAML`: Several configuration files for Flutter projects are in the .yaml format.
   4. `ARB Editor`: .arb files are what Flutter uses for localization (translation).
   5. `Code Spell Checker`: Especially when writing documentation, it's good to have your IDE check your human english as well.
      1. Or your Spanish, French, etc. with extension **add-ons**
   6. `Inno Setup`: If you're planning on releasing Windows apps publicly, you will need to write inno setup scripts.
   7. `Markdown All in One`: simplifies editing and previewing markdown files (like this one)
   8. There's also plugins for all your favorite LLMs, but those aren't free.

## <br>Maintaining Momentum

Thanks for using Open UI! We hope you find it helpful.

All that we ask is that you leave the credits/acknowledgements to YWT in the code.

That, and/or donate via one of the many options we provide.

### <br>Building with user customization in mind

As your app grows, use [Open UI](https://github.com/YWT-LLC/open_ui) to keep things Ez

* [Responsive design](https://github.com/YWT-LLC/open_ui/tree/main/lib/src/widgets/responsive_design): `Widget`s that aid in building responsive UI/UX
* [Screen reader support](https://github.com/YWT-LLC/open_ui/tree/main/lib/src/widgets/screen_reader_support): `Widget`s with streamlined `Semantics`
* [User customization](https://github.com/YWT-LLC/open_ui/tree/main/lib/src/widgets/user_customization): Wrapper `Widget`s that respond to `EzConfig` data when the `ThemeData` doesn't cut it
* [Helpers](https://github.com/YWT-LLC/open_ui/tree/main/lib/src/widgets/helpers): Lots of other `Widget`s and functions to make your life Ez, but don't squarely fit into the above categories

### <br>Localization

aka translation. Add new text to the language files in lib/l10n and reference them in the dart code with `Lang`

There is a step between: after editing the .arb files, run 
``` bash
flutter gen-l10n
``` 
to generate the new aliases.

## <br>Credits

A11how began with [Open UI](https://www.ywt.llc/#/products/open-ui)'s app generation service.

It is free and open source, maintained by [YWT](https://www.ywt.llc/).

<br>**P.S.** `Getting Started` and `Maintaining Momentum` are for YWT, we recommend (re)moving them if this project is going to be made public.
