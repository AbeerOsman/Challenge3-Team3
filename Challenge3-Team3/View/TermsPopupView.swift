import SwiftUI

struct TermsPopupView: View {
    
    @ObservedObject var viewModel: TermsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            
            // العنوان الرئيسي في الوسط
            Text("الشروط والأحكام")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 24)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView {
                VStack(alignment: .trailing, spacing: 16) {
                    
                    Group {
                        Text("1. مقدمة")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("باستخدامك لهذا التطبيق، فإنك تقرّ وتوافق على الالتزام بهذه الشروط والأحكام كاملة. في حال عدم الموافقة، يرجى عدم استخدام التطبيق.")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("2. طبيعة الخدمة")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("التطبيق يوفر منصة تقنية للتواصل فقط بين:\n- الأشخاص الصم\n- مترجمي لغة الإشارة\n\nالتطبيق لا يقدّم خدمات ترجمة بنفسه ولا يضمن:\n- دقة الترجمة\n- جودة التواصل\n- أهلية أو اعتماد أي مترجم")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("3. العلاقة بين المستخدمين")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("أي تواصل أو اتفاق يتم بين الأصم والمترجم هو:\n- علاقة مباشرة بين الطرفين\n- لا يعتبر التطبيق طرفًا فيها\n\nالتطبيق غير مسؤول عن:\n- أي إساءة استخدام\n- سوء تفاهم\n- أضرار نفسية، مهنية، أو قانونية\n- نتائج الترجمة أو القرارات المبنية عليها")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("4. الدفع والاتفاقات المالية")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("التطبيق لا يتدخل في أي عمليات دفع\nأي اتفاق مالي يتم:\n- خارج التطبيق\n- وبالتراضي الكامل بين الطرفين\n\nالتطبيق:\n- لا يضمن استرجاع الأموال\n- لا يتحمل أي مسؤولية عن النزاعات المالية\n- لا يوفّر حماية دفع أو وساطة مالية")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("5. المسؤولية القانونية")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("المستخدم يتحمل المسؤولية الكاملة عن:\n- استخدامه للتطبيق\n- المحتوى الذي يشاركه\n- أي اتفاق أو تعامل يتم مع مستخدم آخر\n\nالتطبيق غير مسؤول عن:\n- أي خسائر مباشرة أو غير مباشرة\n- أضرار ناتجة عن الاعتماد على الترجمة\n- انقطاع الخدمة أو أخطاء تقنية")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("6. الاستخدام الممنوع")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("يُمنع استخدام التطبيق في:\n- أي نشاط غير قانوني\n- الاحتيال أو انتحال الشخصية\n- الإساءة، التهديد، أو التحرش\n- مشاركة محتوى مسيء أو مخالف للآداب\n- تسجيل المكالمات أو المحادثات دون موافقة الطرف الآخر (حسب القوانين المحلية)\n\nويحق لإدارة التطبيق:\n- إيقاف أو حذف الحساب دون إشعار مسبق عند مخالفة الشروط")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("7. الخصوصية والمحتوى")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("المستخدم مسؤول عن المعلومات التي يشاركها\nالتطبيق لا يتحمل مسؤولية:\n- تسريب معلومات بسبب مشاركة المستخدم لها\nقد يتم تخزين بعض البيانات لأغراض تشغيلية أو تحسين الخدمة\n(يفضل يكون فيه سياسة خصوصية مستقلة)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("8. عدم الضمان")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("الخدمة تُقدّم “كما هي” دون أي ضمانات صريحة أو ضمنية\nالتطبيق لا يضمن:\n- توفر الخدمة دائمًا\n- خلوها من الأخطاء")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("9. التعديلات")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("يحق لإدارة التطبيق تعديل الشروط والأحكام في أي وقت\nاستمرار استخدام التطبيق يعني الموافقة على التعديلات")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider().frame(height: 2)
                    
                    Group {
                        Text("10. القانون المعمول به")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        Text("تخضع هذه الشروط لأنظمة وقوانين المملكة العربية السعودية\nأي نزاع يخضع للاختصاص القضائي داخل المملكة")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    TermsPopupView(viewModel: TermsViewModel())
}
