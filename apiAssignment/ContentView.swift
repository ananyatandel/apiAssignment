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
    @State private var favoriteJokes = [Joke]() // store favorite jokes here
    @ObservedObject var viewModel = JokesViewModel()

    // fetch jokes async from API
    func fetchAllJokes() async {
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

    // list display
    var body: some View {
        NavigationView {
            List(jokes) { joke in
                NavigationLink(destination: JokeDetailView(joke: joke, isFavorite: favoriteJokes.contains(where: { $0.id == joke.id }), favoriteJokes: $favoriteJokes)) {
                    VStack(alignment: .leading) {
                        Text(joke.category)
                            .bold()
                        Text(joke.setup ?? "")
                    }
                }
            }
            .onAppear {
                Task {
                    await fetchAllJokes() // fetch jokes when the view appears
                }
            }
            .navigationTitle("Click to Reveal Joke")
            .navigationBarItems(trailing: NavigationLink(destination: FavoritesView(favoriteJokes: $favoriteJokes)) {
                Text("Your Favorites")
            })
        }
    }
}

// detail view to display individual joke
struct JokeDetailView: View {
    let joke: Joke
    @State private var isFavorite: Bool // mark joke as favorite
    @State private var rating: Int? = nil // thumbs up/down
    @Binding var favoriteJokes: [Joke] // binding to the favorite jokes

    // initialize JokeDetailView with favoriteJokes
    init(joke: Joke, isFavorite: Bool, favoriteJokes: Binding<[Joke]>) {
        self.joke = joke
        self._isFavorite = State(initialValue: isFavorite)
        self._favoriteJokes = favoriteJokes
    }

    // how data (jokes) will be displayed and in what order of buttoms
    // detail view appearance
    var body: some View {
        VStack {
            Text(joke.category)
                .font(.headline)
            Text(joke.setup ?? "")
                .padding()
                .multilineTextAlignment(.center)
            Text(joke.delivery ?? "")
                .padding()
                .multilineTextAlignment(.center)

            // rating buttons (thumbs up or down)
            HStack {
                Button(action: {
                    rating = 1 // Thumbs-up
                }) {
                    // button appearance
                    Image(systemName: "hand.thumbsup")
                        .padding()
                        .background(rating == 1 ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    rating = 0 // Thumbs-down
                }) {
                    // button appearance
                    Image(systemName: "hand.thumbsdown")
                        .padding()
                        .background(rating == 0 ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            // display message
            if let rating = rating {
                Text(rating == 1 ? "Yay :)" : "Sorry :(")
                    .foregroundColor(rating == 1 ? .green : .red)
                    .padding()
            }

            // button to mark/unmark the joke as a favorite
            Button(action: {
                isFavorite.toggle()

                if isFavorite {
                    favoriteJokes.append(joke)
                } else {
                    favoriteJokes.removeAll { $0.id == joke.id }
                }
            }) {
                Text(isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // share joke button
            Button(action: {
                let jokeText = "\(joke.setup ?? "")\n\(joke.delivery ?? "")"
                let activityViewController = UIActivityViewController(activityItems: [jokeText], applicationActivities: nil)

                // access the window scene's windows
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first?.rootViewController {
                    window.present(activityViewController, animated: true, completion: nil)
                }
            }) {
                // button appearance
                Text("Share")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Joke Detail View")
    }
}

// Favorites view
struct FavoritesView: View {
    @Binding var favoriteJokes: [Joke] // bind to  favorite jokes

    var body: some View {
        NavigationView {
            List(favoriteJokes) { joke in
                NavigationLink(destination: JokeDetailView(joke: joke, isFavorite: true, favoriteJokes: $favoriteJokes)) {
                    VStack(alignment: .leading) {
                        Text(joke.category)
                            .bold()
                        Text(joke.setup ?? "")
                    }
                }
            }
            .navigationTitle("Your Favorites")
        }
    }
}

// preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        JokesView()
    }
}
