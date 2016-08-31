import Foundation

public class Config {
    public enum EnvironmentType : String {
        case Staging = "Staging"
        case Production = "Production"
    }

    public enum ConfigurationType : String {
        case Release = "Release"
        case Adhoc = "Adhoc"
        case Debug = "Debug"
    }

    public static let environment:EnvironmentType = .Staging
    public static let configuration:ConfigurationType = .Debug
}
