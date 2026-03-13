import Supabase
import Foundation

enum SupabaseClientProvider {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "https://mospyxbxupfllpvmusbf.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vc3B5eGJ4dXBmbGxwdm11c2JmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNjE1ODIsImV4cCI6MjA3MjkzNzU4Mn0.MGzYgo8rqA5YLAZtw6IaWIN98mrKdXrGjVK347SAEVs"
    )
}
