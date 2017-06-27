# Changelog Natrium

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
