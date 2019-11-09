//
//  GameEffect.swift
//  words
//
//  Created by Chris on 06/11/2019.
//  Copyright © 2019 Chris. All rights reserved.
//

import Foundation
import Combine
import Redux

public typealias GameEffect = AnyEffect<GameAction, GameDependencies>

public struct ValidationEffect: Effect {
    let oldBoard: Board
    let newBoard: Board

    init(oldBoard: Board, newBoard: Board) {
        self.oldBoard = oldBoard
        self.newBoard = newBoard
    }

    var intersect: Intersect {
        oldBoard.isEmpty ? .withMiddle : .withExisting
    }

    public func mapToAction(dependencies: GameDependencies) -> AnyPublisher<GameAction, Never> {
        let subject = PassthroughSubject<GameAction, Never>()
        dependencies.backgroundDispatch {
            let candidates = CompoundPlacement(oldBoard: self.oldBoard, newBoard: self.newBoard)
                .candidates(on: self.newBoard, intersect: self.intersect)
            switch candidates {
            case let .invalidPlacements(placements):
                subject.send(ValidationAction.Misplaced(placements: placements))
            case let .candidates(candidates):
                switch candidates.validate(with: dependencies.validator) {
                case let .invalidCandidates(candidates):
                    subject.send(ValidationAction.Invalid(candidates: candidates))
                case let .validCandidates(candidates):
                    let score = candidates.calculateScore(oldBoard: self.oldBoard, newBoard: self.newBoard)
                    subject.send(ValidationAction.Valid(score: score))
                }
            }
        }
        return subject.eraseToAnyPublisher()
    }
}

public extension ValidationEffect {
    init(state: GameState) {
        oldBoard = state.board
        newBoard = state.turn.board
    }
}

public struct NoEffect: Effect {
    public func mapToAction(dependencies: GameDependencies) -> AnyPublisher<GameAction, Never> {
        Just(NoAction()).eraseToAnyPublisher()
    }
}
