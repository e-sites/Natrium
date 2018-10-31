# Changelog Natrium

## v6.0.4 (31-10-2018)
- Fixed 'INFOPLIST_FILE path is not work'. [Issue #11](https://github.com/e-sites/Natrium/issues/11). `SRC_ROOT` and `PROJECT_DIR` are now parsed.

## v6.0.3 (22-10-2018)
- Make AppIcon.appiconset directory readable

## v6.0.2 (11-10-2018)
- Make AppIcon.appiconset Content.json structure the same as Xcode10
- Create appiconset directory if it doesn't exists

## v6.0.1 (03-09-2018)
- Fixed '"Config.swift" file not generate '. [Issue #8](https://github.com/e-sites/Natrium/issues/8).

## v6.0.0 (27-09-2018)
- Made available for Xcode 10's new build system

## v5.9.0 (19-09-2018)
- Updated to Swift 4.2 / Xcode10
- Changed `#error` handling
- Added `#error` type

## v5.8.2 (02-09-2018)
- Resolved #7 ("Config.swift" file not generate)

## v5.8.1 (20-07-2018)
- Fixed a bug that would not write to `Config.swift`

## v5.8.0 (13-07-2018)
- Implemented Francium for file system operations

## v5.7.2 (10-07-2018)
- Only update icon assets if the original icon is updated.

## v5.7.1 (09-07-2018)
- Fixed 'Bool and Int values are not overridden per target'. [Issue #4](https://github.com/e-sites/Natrium/issues/4).

## v5.7.0 (04-07-2018)
- A seperate `NatriumConfig` objective-c file is generated.

## v5.6.1 (03-07-2018)
- Fixed a bug where target specific plist settings would not parse. [Issue #3](https://github.com/e-sites/Natrium/issues/3)

## v5.6.0 (19-12-2017)
- Added carthage support

## v5.5.0 (13-12-2017)
- Manual installation, without CocoaPods
- Removed `update_podfile` setting
- Added `class_name` setting (for manual installation)

## v5.4.1 (17-11-2017)
- Non-breaking linespaces in logging

## v5.4.0 (17-11-2017)
- Added a `objective-c` setting. To use Natrium in objective-c classes.

## v5.3.6 (17-11-2017)
- Fixed a bug where a XcodeEdit dictionary would not parse to `[String: String]`. Changed it to `[String: Any]`

## v5.3.5 (08-11-2017)
- Fixed a bug when using spaces in file paths in the `plists` directive
- Added `line_length` swiftlint ignore in Config.swift

## v5.3.4 (07-11-2017)
- Fixed a bug when scaling the app-icon 

## v5.3.3 (06-11-2017)
- Fixed a bug where Natrium would use the .lock file incorectly

## v5.3.2 (03-11-2017)
- Fixed a bug in the `launch_screen_versioning` parser for launchscreens with multiple labels

## v5.3.1 (02-11-2017)
- Fixed a bug when app icon images are not 1024x1024
- Fixed a bug conserning the lock file
- Set the xcconfig include path to an absolute path instead of relative

## v5.3.0 (26-10-2017)
- Added unit tests
- natrium.log output

## v5.2.1 (26-10-2017)
- Fixed a bug in the `Config.swift` creation

## v5.2.0 (26-10-2017)
- `Package.swift`

## v5.1 (24-10-2017)
- `no_timestamp` argument

## v5.0 (23-10-2017)
- Converted it into a swift script instead of ruby

## v4.1 (09-10-2017)
- Allow `"*"` as environment to match all the environments
- Made `Config.swift` (default) swiftlint valid

## v4.0.1 (09-10-2017)
- Fixed a bug when the `appicon.original` could not be found

## v4.0 (23-08-2017)
- Xcode9 and swift4 compatible

## v3.0 (27-06-2017)
- Added `idioms` to the `appicon` configuration
- Renamed `build-config.yml` to `.natrium.yml`

## v2.3 (20-03-2017)
- Add the [Natrium] build phase automatically

## v2.2.3 (10-03-2017)
- Get app version beforehand

## v2.2.2 (28-11-2016)
- Better swift version check

## v2.2.1 (18-10-2016)
- Prepend "v" for version in `launchScreenStoryboard`

## v2.2 (07-10-2016)
- Added `misc` and `launchScreenStoryboard` 

## v2.1.3 (28-09-2016)
- bash script alteration

## v2.1.2 (26-09-2016)
- ruby location

## v2.1.1 (23-09-2016)
- Improved logging

## v2.1 (20-09-2016)
- Automatically detect swift2.2, swift2.3 or swift3.0
- Removed `legacy` input for `app_ribbon`

## v2.0.2 (02-09-2016)
- Use proper asset filenames (@2x, @3x)

## v2.0.1 (01-09-2016)
- Minor bug fixes

## v2.0.0 (30-08-2016)
- Changed the way xcconfig files are generated

## v1.7.5 (30-08-2016)
- Added `configuration` default variable to `Config.swift`

## v1.7.4 (23-08-2016)
- Added backwards compatibility for ruby 2.0
- Added `legacy` handler for `appicon` variable

## v1.7.3 (22-08-2016)
- Improved app ribbon creation

## v1.7.2 (12-08-2016)
- Extra logging for `xcconfig` variables

## v1.7.1 (10-08-2016)
- Fixed small `natrium_variables` bug

## v1.7 (10-08-2016)
- Xcconfig variables per configuration

## v1.6.2 (04-08-2016)
- Allow editing entitlements files

## v1.6.1 (28-07-2016)
- Example bug fix

## v1.6 (28-07-2016)
- Added `natrium_variables`

## v1.5.1 (25-07-2016)
- `Imagemagick` for ribbon creation is optional. Does not throw an error

## v1.5 (21-07-2016)
- Added `target_specific` values

## v1.4.1 (15-07-2016)
- Fixed a bug where paths contaning a space would throw an shell error

## v1.4 (04-07-2016)
- Added support to alter other plist files then the `Info.plist`

## v1.3.3 (04-07-2016)
- Fixed `files` directive

## v1.3.2 (04-07-2016)
- Extra error checking when parsing .yml file

## v1.3.1 (15-06-2016)
- Increased ribbon font size

## v1.3 (15-06-2016)
- Added `appicon` directive

## v1.2 (09-06-2016)
- Added `files` directive

## v1.1 (12-05-2016)
- Easier setup with CocoaPods
- Multiple platforms (iOS / OSX)

## v1.0 (11-05-2016)
- Initial release
