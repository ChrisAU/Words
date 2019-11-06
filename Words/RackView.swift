//
//  RackView.swift
//  Words
//
//  Created by Chris on 06/11/2019.
//  Copyright © 2019 Chris. All rights reserved.
//

import SwiftUI
import WordsCore

struct RackView: View {
    @EnvironmentObject var device: Device

    var tiles: [Tile]

    var body: some View {
        Stack(verticalIfPortrait: false) {
            ForEach(tiles) { tile in
                TileView(tile: tile)
            }
        }
    }
}

struct RackView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RackView(tiles: Tile.preview).colorScheme(.dark)

            RackView(tiles: Tile.preview).colorScheme(.light)
        }.environmentObject(Device())
    }
}
