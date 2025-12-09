import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "F7F9FF"), Color(hex: "F2F6FF")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("الملف الشخصي")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // Card Container
                VStack(spacing: 0) {
                    // Profile Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        
                        HStack(spacing: 16) {
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 55))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("سعود عبدالله الشمري")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: "F77575"))
                                        .frame(width: 5, height: 5)
                                    
                                    Text("مدفوع")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "F77575"))
                                }
                            }
                            
                        }
                    
                    }
                    .padding(16)
                    
                    // Stats Section
                    HStack(spacing: 12) {
                        // Age Card
                        VStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 25))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("العمر")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                            
                            Text("35")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "9F610D"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        
                        // Gender Card
                        VStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 25))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("الجنس")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                            
                            Text("ذكر")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "9F610D"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        
                        // Height Card
                        VStack(spacing: 6) {
                            Image(.ريال)
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(Color(hex: "1428A0"))
                                .frame(width: 25, height: 25)

                            
                            Text("المبلغ / بالساعة")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                            
                            Text("50")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "9F610D"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                    }
                    
                    .padding(16)
                
                    
                    // Sign Language Level
                    HStack(spacing: 12) {
                        
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "1428A0"))
                        
                        Text("المستوى بلغة الإشارة")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "9F610D"))
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "9F610D"))
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "9F610D"))
                        }
                        .padding(.trailing, 40)
                        
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F5F7FB"))
                    .cornerRadius(10)
                    .padding(16)
                    
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Categories Header
                    HStack(spacing: 0) {
                        
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "1428A0"))
                            .padding(.leading, 10)
                        
                        
                        Text("المجالات")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .padding(.leading, 6)
                        
                        Spacer()
                    }
                    .padding(16)
                    .padding(.bottom, 0)
                    
                    // Categories
                    HStack(spacing: 10) {
                        // Drawing
                        VStack(spacing: 6) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("الرسم")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        
                        // Sports
                        VStack(spacing: 6) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("الرياضة")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        
                        // Photography
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("التصوير")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                        
                        // Education
                        VStack(spacing: 6) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "1428A0"))
                            
                            Text("التعليم")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                        .background(Color(hex: "F5F7FB"))
                        .cornerRadius(10)
                    }
                    .padding(16)
                    .padding(.top, 0)
                    
                    // Edit Button
                    Button(action: {}) {
                        Text("تعديل الملف الشخصي")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "1428A0"))
                            .cornerRadius(10)
                    }
                    .padding(16)
                }
                .background(.white)
                .cornerRadius(20)
                .padding(16)
                
                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}


#Preview {
    ContentView()
}
