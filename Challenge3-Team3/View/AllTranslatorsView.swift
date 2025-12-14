//
//  AllTranslatorsView.swift
//  Challenge3Team3
//
//  Created by Abeer Jeilani Osman  on 04/06/1447 AH.
//
import SwiftUI

// MARK: - Translator Level Enum
enum TranslatorLevel: String {
    case beginner = "مبتدئ"
    case intermediate = "متوسط"
    case advanced = "متقدم"
    
    var display: String { rawValue }
}

struct AllTranslatorsView: View {
    @ObservedObject var viewModel: TranslationViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(alignment: .trailing) {
                LevelFilterView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 48)
                
                ScrollView(.vertical) {
                    TranslatorCardsView(viewModel: viewModel)
                }
            }
        }
        .background(Color(hex: "F2F2F2"))
        .environment(\.layoutDirection, .rightToLeft)
        .navigationTitle("المترجمون المتاحون")
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
                ProgressView("جاري التحميل...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("حدث خطأ أثناء تحميل البيانات")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                    
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
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
                            Text("حاول مرة أخرى")
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
                    
                    Text("لا يوجد مترجمون متاحون")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                    
                    if viewModel.selectedLevel != nil {
                        Text("لا توجد نتائج لهذا المستوى")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        
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
        VStack(alignment: .trailing, spacing: 12) {
            Text("اختر المستوى")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            HStack(spacing: 8) {
                FilterButton(
                    title: "مبتدئ",
                    isSelected: viewModel.selectedLevel?.rawValue == TranslatorLevel.beginner.rawValue
                ) {
                    if viewModel.selectedLevel?.rawValue == TranslatorLevel.beginner.rawValue {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.beginner)
                    }
                }
                FilterButton(
                    title: "متوسط",
                    isSelected: viewModel.selectedLevel?.rawValue == TranslatorLevel.intermediate.rawValue
                ) {
                    if viewModel.selectedLevel?.rawValue == TranslatorLevel.intermediate.rawValue {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.intermediate)
                    }
                }
                FilterButton(
                    title: "متقدم",
                    isSelected: viewModel.selectedLevel?.rawValue == TranslatorLevel.advanced.rawValue
                ) {
                    if viewModel.selectedLevel?.rawValue == TranslatorLevel.advanced.rawValue {
                        viewModel.clearFilter()
                    } else {
                        viewModel.filterByLevel(.advanced)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    NavigationStack {
        AllTranslatorsView(viewModel: TranslationViewModel())
            .environment(\.layoutDirection, .rightToLeft)
    }
}
