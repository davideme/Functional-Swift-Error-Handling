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
            self.aim().flatMap { target in
                self.launch(target: target, nuke: nuke)
            }
        }
    }
}
//
///// Variant of Either Monad commonly Used in Swift, called Result
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

/// We will only define map and flatMap for our needs in this context
/// We are using the naming convention of the Optional Monad defined in the standard library

protocol Monad {
    associatedtype Value
    associatedtype F: Monad

    /// Using initializer as equivalent of pure
    init(value: Value)
    func flatMap<U>(_ transform: (Value) throws -> F) rethrows -> F where F.Value == U
    func map<U>(_ transform: (Value) throws -> U) rethrows -> F where F.Value == U
}

extension Optional: Monad {
    typealias F = Optional

    init(value: Value) {
        self = .some(value)
    }
//    func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U? {
//        switch self {
//        case let .some(value):
//            return .some(try transform(value))
//        default:
//            return .none
//        }
//    }
}

extension Result: Monad {
    typealias F = Result

    func flatMap<U>(_ transform: (Value) throws -> Result<U, Error>) rethrows -> Result<U, Error> {
        switch self {
        case let .success(value):
            return try transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }

    func map<U>(_ transform: (Value) throws -> U) rethrows -> Result<U, Error> {
        switch self {
        case let .success(value):
            return .success(try transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }
}


struct NuclearMonad<NukeMonad: Monad, TargetMonad: Monad, AttackMonad: Monad>
        where NukeMonad.Value == Nuke,
        TargetMonad.Value == Target,
        AttackMonad.Value == (Nuke, Target) {
    func arm() -> NukeMonad {
        return NukeMonad(value: Nuke())
    }

    func aim() -> TargetMonad {
        return TargetMonad(value: Target())
    }

    func attackMonadic() -> AttackMonad {
//        return arm().flatMap { (nuke: Nuke) in
//            aim().map { (target:Target) -> (Nuke, Target) in
//                return (nuke, target)
//            }
//        }

        return arm().flatMap(aiming)
    }

    func aiming(nuke: Nuke) -> AttackMonad {
        aim().map { (target:Target) -> (Nuke, Target) in
            return (nuke, target)
        }
    }
}
