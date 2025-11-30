//
//  AllTranslatorsView.swift
//  Challenge3Team3
//
//  Created by Abeer Jeilani Osman  on 04/06/1447 AH.
//

import SwiftUI

struct AllTranslatorsView: View {
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                LevelFilterView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                ScrollView(.vertical) {
                    TranslatorCardsView(viewModel: viewModel)
                        .padding(.top, 10)
                }
            }
        }
        .background(Color(hex: "F2F2F2"))
        .environment(\.layoutDirection, .rightToLeft)
        .navigationTitle("المترجمين المتاحيين")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.translators.isEmpty {
                viewModel.fetchTranslators()
            }
        }
    }
}

// MARK: - Translator Cards View (Show ALL translators)
struct TranslatorCardsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView("جاري التحميل...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("حدث خطأ في تحميل البيانات")
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
                            Text("إعادة المحاولة")
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
                    
                    Text("لا يوجد مترجمين متاحين")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    if viewModel.selectedLevel != nil {
                        Text("لا توجد نتائج لهذا المستوى")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button {
                            viewModel.clearFilter()
                        } label: {
                            Text("عرض جميع المترجمين")
                                .foregroundColor(Color(hex: "0D189F"))
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.top, 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.translators) { translator in
                        TranslatorCard(translator: translator, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    NavigationView {
        AllTranslatorsView()
    }
}
