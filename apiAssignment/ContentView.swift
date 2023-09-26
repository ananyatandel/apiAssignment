//
// ContentView.swift
// apiAssignment
//
// Created by Ananya Tandel on 9/18/23.


import SwiftUI

// represent the JSON response containing jokes
struct JokeResponse: Codable {
    var error: Bool
    var amount: Int
    var jokes: [Joke]
}

// represent an individual joke
struct Joke: Codable, Identifiable {
    var id: Int
    var category: String
    var type: String
    var setup: String?
    var delivery: String?
    var flags: Flags
    var safe: Bool
    var lang: String
}

// represent flags associated with a joke
struct Flags: Codable {
    var nsfw: Bool
    var religious: Bool
    var political: Bool
    var racist: Bool
    var sexist: Bool
    var explicit: Bool
}



// main view
struct JokesView: View {
    @State var jokes = [Joke]()

    // fetch jokes async from API
    func getAllJokes() async {
        do {
            let url = URL(string: "https://v2.jokeapi.dev/joke/Any?amount=20")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // decode the received JSON data into JokeResponse
            let decodedData = try JSONDecoder().decode(JokeResponse.self, from: data)
            jokes = decodedData.jokes
        } catch {
            print(error)
        }
    }

    var body: some View {
        NavigationView {
            List(jokes) { joke in
                NavigationLink(destination: JokeDetailView(joke: joke)) {
                    VStack(alignment: .leading) {
                        Text(joke.category)
                            .bold()
                        Text(joke.setup ?? "") // display setup
                        // Text(joke.delivery ?? "") // display delivery
                    }
                }
            }
            .onAppear {
                Task {
                    await getAllJokes() // fetch jokes when the view appears
                }
            }
            .navigationTitle("Click to Reveal Joke")
        }
    }
}




// detail view to display individual joke
struct JokeDetailView: View {
    let joke: Joke

    var body: some View {
        VStack {
            Text(joke.category)
                .font(.headline)
            Text(joke.setup ?? "") // display setup
                .padding()
                .multilineTextAlignment(.center)
            Text(joke.delivery ?? "") // display delivery
                .padding()
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Joke Detail View")
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        JokesView()
    }
}
