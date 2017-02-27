//
//  GameViewController.swift
//  Pentago
//
//  Created by Itai Ferber on 5/13/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import UIKit
import SCLAlertView

enum Victory: Int {
    case None
    case Player1
    case Player2
    case Tie
}

class GameViewController: UIViewController, GameViewDelegate {
    // MARK: Properties
    var player1Label: UILabel! = nil
    var player2Label: UILabel! = nil
    var gameView: GameView! = nil

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Player 1: Play Marble"

        let createLabel = { (text: String) -> UILabel in
            let label = UILabel()
            label.text = text
            label.font = UIFont.boldSystemFontOfSize(72)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Set up the player labels.
        self.player1Label = createLabel("PLAYER1")
        self.player1Label.textColor = UIColor.colorForPlayer(.Player1)
        self.view.addSubview(player1Label)
        self.player1Label.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
        self.player1Label.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.player1Label.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true

        self.player2Label = createLabel("PLAYER2")
        self.player2Label.textColor = UIColor.colorForPlayer(.None)
        self.view.addSubview(player2Label)
        self.player2Label.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.player2Label.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
        self.player2Label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Set up the game view itself.
        self.gameView = GameView(frame: CGRectInset(self.view.frame, 100, 100))
        self.gameView.translatesAutoresizingMaskIntoConstraints = false
        self.gameView.delegate = self
        self.view.addSubview(gameView)
        self.gameView.widthAnchor.constraintEqualToConstant(gameView.frame.width).active = true
        self.gameView.heightAnchor.constraintEqualToConstant(gameView.frame.height).active = true
        self.gameView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.gameView.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true

        // Show a navigation bar so the game can be exited.
        self.navigationController!.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Hide the navigation bar so it doesn't appear in the intro view
        // controller.
        self.navigationController!.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: Game View Delegate Methods
    func playerDidPlaceMarble(player: Owner) {
        self.title = "Player \(player == .Player1 ? 1 : 2): Rotate Quadrant"
    }

    func player(player: Owner, didCompleteTurnWithWinningChains chains: [Chain]) {
        guard !chains.isEmpty else {
            // No victory; just switch to the other player and continue.
            self.title = "Player \(player == .Player1 ? 2 : 1): Play Marble"

            let player1Color: UIColor
            let player2Color: UIColor
            if player == .Player1 {
                player1Color = UIColor.colorForPlayer(.None)
                player2Color = UIColor.colorForPlayer(.Player2)
            } else {
                player1Color = UIColor.colorForPlayer(.Player1)
                player2Color = UIColor.colorForPlayer(.None)
            }

            UIView.transitionWithView(self.player1Label, duration: 0.25, options: .TransitionCrossDissolve, animations: {self.player1Label.textColor = player1Color}, completion: nil)
            UIView.transitionWithView(self.player2Label, duration: 0.25, options: .TransitionCrossDissolve, animations: {self.player2Label.textColor = player2Color}, completion: nil)
            return
        }

        // There's a victory. Figure out who won.
        let victor = getVictor(chains)
        switch victor {
        case .None:
            fatalError("This shouldn't happen!")

        case .Player1:
            fallthrough
        case .Player2:
            self.title = "Player \(victor == .Player1 ? 1 : 2) Wins!"
            if victor.rawValue == player.rawValue {
                SCLAlertView().showTitle("You Won!", subTitle: "You beat player \(victor == .Player1 ? 1 : 2).", duration: 0, completeText: "Done", style: .Success, colorStyle: UIColor.hexColorForPlayer(player))
            } else {
                SCLAlertView().showTitle("You Lost!", subTitle: "You lost to player \(victor == .Player1 ? 1 : 2).", duration: 0, completeText: "Done", style: .Error, colorStyle: UIColor.hexColorForPlayer(player))
            }

        case .Tie:
            self.title = "Tie!"
            SCLAlertView().showTitle("Tie!", subTitle: "Neither player has won.", duration: 0, completeText: "Done", style: .Info, colorStyle: UIColor.hexColorForPlayer(.None))
        }
    }

    private func getVictor(chains: [Chain]) -> Victory {
        guard !chains.isEmpty else {
            return .None
        }

        var victor: Victory = .None
        for chain in chains {
            if victor.rawValue == chain.owner.rawValue {
                continue
            } else if victor == .None {
                victor = Victory(rawValue: chain.owner.rawValue)!
            } else {
                victor = .Tie
                break
            }
        }

        return victor
    }

    func playerDidFillBoardWithNoVictory() {
        self.title = "Tie!"
        SCLAlertView().showTitle("Tie!", subTitle: "Neither player has won.", duration: 0, completeText: "Done", style: .Info, colorStyle: UIColor.hexColorForPlayer(.None))
    }
}
