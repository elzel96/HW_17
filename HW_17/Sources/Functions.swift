//
//  Functions.swift
//  HW_17
//
//  Created by Helena on 23.09.2023.
//

import Foundation

func indexOf(character: Character, _ array: [String]) -> Int {
   array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    index < array.count
    ? Character(array[index])
    : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }

    return str
}

func generateRandomPassword() -> String {
    String((2..<4).map{ _ in String().printable.randomElement()! })
}
