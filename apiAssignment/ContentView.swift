//
// ContentView.swift
// apiAssignment
//
// Created by Ananya Tandel on 9/18/23.


import SwiftUI

struct Joke: Codable, Identifiable {
    var id: Int
    var category: String
    var type: String
    var joke: String
    var flags: Flags
    var safe: Bool
    var lang: String
    
//    enum CodingKeys: String, CodingKey {
//            case id = "id"
//            case category
//            case type
//            case joke
//            case flags
//            case safe
//            case lang
//        }
}

struct Flags: Codable {
    var nsfw: Bool
    var religious: Bool
    var political: Bool
    var racist: Bool
    var sexist: Bool
    var explicit: Bool
}

struct JokesView: View {
    @State var joke: Joke?  // Store a single joke

    // fetch a joke from API
    func getJoke() async {
        do {
            // define url
            let url = URL(string: "https://v2.jokeapi.dev/joke/Any?amount=20")!
            // fetch data from url
            let (data, _) = try await URLSession.shared.data(from: url)

            // decode the response into a single Joke object
            joke = try JSONDecoder().decode(Joke.self, from: data)
        } catch {
            // error message
            print(error)
        }
    }

    var body: some View {
        NavigationView {
            if let joke = joke {
                JokeDetailView(joke: joke)
            } else {
                Text("Loading...")  // show a loading message
                    .onAppear {
                        Task {
                            await getJoke()
                        }
                    }
            }
        }
        .navigationTitle("Jokes") // nav title
    }
}

struct JokeDetailView: View {
    let joke: Joke // display in detail view

    var body: some View {
        VStack {
            Text(joke.category)
                .font(.headline)
            Text(joke.joke)
                .padding()
        }
        .navigationTitle("Joke Detail View") // detail view title
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        JokesView()
    }
}

