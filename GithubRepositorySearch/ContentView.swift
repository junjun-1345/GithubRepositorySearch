import SwiftUI

struct ContentView: View {
//     ViewModelをインスタンス化
//    @ObservedObjectの属性が付いたオブジェクトのプロパティが変化すると、ビューは自動的に再描画されます。provider的な?
    @ObservedObject var viewModel = RepositoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
//                 $viewModel.queryの値とバインディング
                TextField("Search Repositories", text: $viewModel.query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                    Spacer()
                } else {
                    List(viewModel.repositories) { repository in
                        VStack(alignment: .leading) {
                            Text(repository.name)
                                .font(.headline)
                            Text(repository.description ?? "")
                                .font(.subheadline)
                            Link("View on GitHub", destination: URL(string: repository.html_url)!)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("GitHub Search")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
