//
//  JokesViewModel.swift
//  apiAssignment
//
//  Created by Ananya Tandel on 10/6/23.
//

import SwiftUI

class JokesViewModel: ObservableObject {
    @Published var jokes = [Joke]()
    @Published var favoriteJokes = [Joke]()

    func fetchAllJokes() async {
        do {
            let url = URL(string: "https://v2.jokeapi.dev/joke/Any?amount=20")!
            let (data, _) = try await URLSession.shared.data(from: url)

            let decodedData = try JSONDecoder().decode(JokeResponse.self, from: data)
            jokes = decodedData.jokes
        } catch {
            print(error)
        }
    }

}
