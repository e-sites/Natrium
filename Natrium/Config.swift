import Foundation

public class Config {
    public enum EnvironmentType {
        case Staging
        case Production
    }

    public static let environment:EnvironmentType = .Production
}
