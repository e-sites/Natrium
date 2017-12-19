
# Installation CocoaPods

## Step 1

Add the following to your `Podfile`:

```ruby
pod 'Natrium'
```

Run `pod install` or `pod update`

## Step 2

Create `.natrium.yml` in the root of your project (in the same folder as the .xcproject and .xcworkspace files).    
Check the configuration parameters [here](CONFIGURATION.md).

## Step 3

Create a Pre-Action per scheme which runs the following script:

```shell
"${PROJECT_DIR}/Pods/Natrium/bin/natrium" Production
```

The final argument `"Production"` is the actual environment you want to use for that specific scheme.<br>
This way you can create different schemes per environment

![Schemes](Assets/xcode_scheme_cocoapods.png)

⚠️ **Warning:** Don't forget to select your target in the `Provide build settings from...` selectbox
