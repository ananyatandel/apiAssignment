//
//  ContentView.swift
//  apiAssignment
//
//  Created by Ananya Tandel on 9/18/23.
//

import SwiftUI
import CoreData

import SwiftUI

// api source/url: https://jokeapi.dev/

// show the Joke data from the API
struct Joke: Codable, Identifiable {
    var id: Int
    var category: String
    var type: String
    var joke: String
}

// create the main view for displaying a list of jokes
struct JokesView: View {
    @State var jokes = [Joke]() // state property to store the fetched jokes
    
    // fetch jokes from the JokeAPI
    func getAllJokes() async -> () {
        do {
            let url = URL(string: "https://v2.jokeapi.dev/joke/Any")!
            let (data, _) = try await URLSession.shared.data(from: url) // fetch data
            
            // json response into an array of Jokes
            jokes = try JSONDecoder().decode([Joke].self, from: data)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            List(jokes) { joke in
                // navigate to the JokeDetailView
                NavigationLink(destination: JokeDetailView(joke: joke)) {
                    VStack(alignment: .leading) {
                        Text(joke.category)
                        Text(joke.joke)
                    }
                }
            }
            .task {
                await getAllJokes() // display jokes when the view appears
            }
        }
        .navigationTitle("Jokes") // title
    }
}

// detail view for displaying an individual joke
struct JokeDetailView: View {
    let joke: Joke // display joke
    
    var body: some View {
        VStack {
            Text(joke.category)
                .font(.headline)
            Text(joke.joke)
                .padding()
        }
        .navigationTitle("Joke Detail") // detail view title
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        JokesView() // preview screen
    }
}
