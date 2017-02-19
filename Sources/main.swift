/// Model
struct Nuke {}
struct Target {}
struct Impacted {}

enum NukeError: Error {
    case SystemOffline
    case RotationNeedsOil
    case MissedByMeters(meters: Int)
}

/// Throwing Errors
struct NuclearThrows {
    func arm() throws -> Nuke {
        throw NukeError.SystemOffline
    }

    func aim() throws -> Target {
        throw NukeError.RotationNeedsOil
    }

    func launch(target: Target, nuke: Nuke) -> Impacted {
        return Impacted()
    }

    func attackImperative() throws -> (Nuke, Target) {
        let nuke = try arm()
        let target = try aim()
        return (nuke, target)
    }
}

/// Optional
struct NuclearOption {
    func arm() -> Nuke? {
        return nil
    }

    func aim() -> Target? {
        return nil
    }

    func launch(target: Target, nuke: Nuke) -> Impacted {
        return Impacted()
    }

    func attackImperative() -> Impacted? {
        if let nuke = arm() {
            if let target = aim()  {
                return launch(target: target, nuke: nuke)
            }
        }
        return nil
    }

    func attackMonadic() -> Impacted? {
        return arm().flatMap { nuke in
            aim().flatMap { target in
                launch(target: target, nuke: nuke)
            }
        }
    }
}

/// Variant of Either Monad commonly Used in Swift, called Result
import Result

struct NuclearResult {
    func arm() -> Result<Nuke, NukeError> {
        return .success(Nuke())
    }

    func aim() -> Result<Target, NukeError> {
        return .success(Target())
    }

    func launch(target: Target, nuke: Nuke) -> Result<Impacted, NukeError> {
        return .failure(.MissedByMeters(meters: 5))
    }

    func attackPatternMatching() -> Result<Impacted, NukeError> {
        switch arm() {
        case let .success(nuke):
            switch aim() {
            case let .success(target):
                return launch(target: target, nuke: nuke)
            case let .failure(error):
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    func attackMonadic() -> Result<Impacted, NukeError> {
        return arm().flatMap { nuke in
            aim().flatMap { target in
                launch(target: target, nuke: nuke)
            }
        }
    }
}
