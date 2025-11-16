//
//  NetworkCalssWithAsyncAwait.swift
//  
//
//  Created by Daniel Braga Barbosa on 16/11/25.
//

import SwiftUI

struct GitHubUser: Codable
{
    let login: String
    let avatarUrl: String
    let bio: String
}

struct NetworkCalssWithAsyncAwait: View
{
    var viewModel = NetworkCalssWithAsyncAwaitViewModel()
    
    @State private var user: GitHubUser?
    
    var body: some View
    {
        VStack(spacing: 20)
        {
            AsyncImage(url: URL(string: user?.avatarUrl ?? ""))
            { image in
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Username default")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio default")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do
            {
                user = try await viewModel.getUser()
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid response")
            } catch GHError.invalidData {
                print("Invalid data")
            } catch {
                print("An unexpected error occurred: \(error)")
            }
        }
    }
    

}

class NetworkCalssWithAsyncAwaitViewModel
{
    func getUser() async throws -> GitHubUser
    {
        let endpoint = "https://api.github.com/users/dbragabarbosa"
        
        guard let url = URL(string: endpoint) else
        {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else
        {
            throw GHError.invalidResponse
        }
        
        do
        {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }
        catch
        {
            throw GHError.invalidData
        }
    }
}

enum GHError: Error
{
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview
{
    NetworkCalssWithAsyncAwait()
}
