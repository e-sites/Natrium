import Foundation

public class Config {
    public enum EnvironmentType: String {
        case staging = "Staging"
        case production = "Production"
    }

    public enum ConfigurationType: String {
        case debug = "Debug"
        case release = "Release"
    }

    public static let environment: EnvironmentType = .staging
    public static let configuration: ConfigurationType = .debug

    public static let testVariableDouble: Double = 1.0
    public static let testVariableString: String = "Target #2"
    public static let testVariableBoolean: Bool = false
    public static let testVariableInteger: Int = 125
}