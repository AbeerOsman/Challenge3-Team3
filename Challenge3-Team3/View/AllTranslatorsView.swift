//
//  AllTranslatorsView.swift
//  Challenge3Team3
//
//  Created by Abeer Jeilani Osman  on 04/06/1447 AH.
//

import SwiftUI

struct AllTranslatorsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                LevelFilterView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 48)
                
                ScrollView(.vertical) {
                    TranslatorCardsView(viewModel: viewModel)
                      
                }
            }
        }
        .background(Color(hex: "F2F2F2"))
        .environment(\.layoutDirection, .leftToRight)
        .navigationTitle("Available Translators")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("  AllTranslatorsView appeared")
            print("   ViewModel User ID: \(viewModel.deafUserId)")
            print("   ViewModel User Name: \(viewModel.deafName)")
            viewModel.clearFilter()
            viewModel.fetchTranslators()
        }
    }
}

// MARK: - Translator Cards View (Show ALL translators)
struct TranslatorCardsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack{
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Error loading data")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        if viewModel.selectedLevel != nil {
                            viewModel.filterByLevel(viewModel.selectedLevel!)
                        } else {
                            viewModel.fetchTranslators()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 180, height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "0D189F"), Color(hex: "0A1280")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else if viewModel.translators.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "D8D8D8"))
                    
                    Text("No translators available")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    if viewModel.selectedLevel != nil {
                        Text("No results for this level")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button {
                            viewModel.clearFilter()
                        } label: {
                            Text("Show all translators")
                                .foregroundColor(Color(hex: "0D189F"))
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.top, 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack{
                    ForEach(viewModel.translators) { translator in
                        TranslatorCard(translator: translator, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct LevelFilterView: View {
    @ObservedObject var viewModel: TranslationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Level")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 8) {
                FilterButton(
                    title: "Beginner",
                    isSelected: viewModel.selectedLevel == .beginner
                ) {
                    if viewModel.selectedLevel == .beginner {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.beginner)
                    }
                }

                FilterButton(
                    title: "Intermediate",
                    isSelected: viewModel.selectedLevel == .intermediate
                ) {
                    if viewModel.selectedLevel == .intermediate {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.intermediate)
                    }
                }

                FilterButton(
                    title: "Advanced",
                    isSelected: viewModel.selectedLevel == .advanced
                ) {
                    if viewModel.selectedLevel == .advanced {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.advanced)
                    }
                }
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "0D189F") : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: "D8D8D8") : .white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "EEEEEE"), lineWidth: 1))
                )
                .fixedSize()
        }
    }
}


#Preview {
    NavigationView {
        AllTranslatorsView(viewModel: TranslationViewModel())
            .environmentObject(TranslationViewModel())
    }
}
