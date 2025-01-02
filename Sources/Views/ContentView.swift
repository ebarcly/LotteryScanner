//
//  ContentView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var isShowingScanner = false
    @FocusState private var focusedField: Int?
    @State private var scrollProxy: ScrollViewProxy?
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 16) {
                        LotteryTypeSelectionView(selectedLotteryType: $viewModel.lotteryType)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        DateSelectionView(selectedDate: $viewModel.drawDate)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        TicketNumbersView(plays: $viewModel.plays)
                            .id("ticketNumbers")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Button(action: { isShowingScanner = true }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Scan Ticket")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: viewModel.checkTicket) {
                            HStack {
                                Image(systemName: "checkmark.square.fill")
                                Text("Check Ticket")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        TipAlert()
                    }
                    .padding()
                    .onAppear { scrollProxy = proxy}
                }
            }
            .coordinateSpace(name: "RefreshControl")
            .background(Color(UIColor.systemGray6))
            .navigationBarTitle("Lottery Scanner", displayMode: .inline)
            .gesture(TapGesture()
                .onEnded({ _ in
                    focusedField = nil
                }))
        }
        .sheet(isPresented: $isShowingScanner) {
            ScannerView(recognizedPlays: $viewModel.plays, scanResult: $viewModel.scanResult)
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct TipAlert: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tip")
                .font(.headline)
            Text("Make sure to double-check your numbers before submitting!")
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(10)
    }
}

struct RefreshControl: View {
    var coordinateSpace: CoordinateSpace
    var onRefresh: () -> Void
    
    @State private var refresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        if !refresh {
                            refresh = true
                            onRefresh()
                        }
                    }
            } else if geo.frame(in: coordinateSpace).maxY < 1 {
                Spacer()
                    .onAppear {
                        refresh = false
                    }
            }
            ZStack(alignment: .center) {
                if refresh {
                    ProgressView()
                }
            }
            .frame(width: geo.size.width)
        }.padding(.top, -50)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
