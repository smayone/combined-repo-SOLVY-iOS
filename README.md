# Testing the SOLVY Bridge Swift Package in Xcode

This guide will help you test the SOLVY Bridge implementation in Xcode.

## Prerequisites
- Xcode 15.0 or later
- iOS 15.0 or later (for testing on device/simulator)
- macOS 12.0 or later (for development)

## Step 1: Create a Test Project
1. Open Xcode
2. Go to File > New > Project
3. Select "App" under iOS
4. Set the following options:
   - Product Name: "SolvyDemo"
   - Interface: "SwiftUI"
   - Language: "Swift"
   - Minimum Deployment: iOS 15.0
5. Click "Next" and choose a location to save the project

## Step 2: Add the SOLVY Package
1. In Xcode, with your project open:
2. Go to File > Add Packages
3. Click the "+" button in the bottom left
4. Choose "Add Local Package"
5. Navigate to and select the `ios` folder containing the Package.swift file
6. Click "Add Package"
7. In the package options dialog:
   - Select both "SolvyCore" and "SolvyApp" products
   - Click "Add Package"

## Step 3: Configure the Test Project
1. Open your project's Info.plist
2. Add the following keys:
   ```
   NSAppTransportSecurity
     NSAllowsArbitraryLoads: YES
   ```
   This allows connection to the local development server

## Step 4: Add Test Code
1. Open ContentView.swift
2. Replace its contents with:
   ```swift
   import SwiftUI
   import SolvyApp
   
   struct ContentView: View {
       var body: some View {
           NavigationView {
               VStack {
                   Text("SOLVY Bridge Demo")
                       .font(.title)
                       .padding()
                   
                   Button("Test Transaction") {
                       let vc = ExampleViewController()
                       if let window = UIApplication.shared.windows.first,
                          let rootVC = window.rootViewController {
                           rootVC.present(vc, animated: true)
                       }
                   }
                   .buttonStyle(.borderedProminent)
               }
           }
       }
   }
   ```

## Step 5: Run and Test
1. Select an iOS Simulator (e.g., iPhone 15 Pro)
2. Click the Run button (▶️) or press Cmd+R
3. Once the app launches:
   - Click "Test Transaction"
   - The example view controller will appear
   - Press the test transaction button
   - Watch the real-time transaction status updates

## Expected Results
- The app should successfully connect to the local server
- You should see the transaction progress through various states
- The progress bar should update in real-time
- Transaction details (hash, block number, etc.) should appear as they become available

## Troubleshooting
If you encounter any issues:

1. Network Connection:
   - Ensure the SOLVY server is running on port 5000
   - Check the baseURL in TransactionBridgeService is correct
   - Verify NSAllowsArbitraryLoads is set in Info.plist

2. Build Errors:
   - Clean the build folder (Cmd+Shift+K)
   - Clean the build cache (Cmd+Option+Shift+K)
   - Re-add the package if necessary

3. Runtime Errors:
   - Check the debug console for detailed error messages
   - Verify the server endpoint responses match expected formats

## Need Help?
If you encounter any issues not covered here, please create an issue in the repository with:
- A description of the problem
- Steps to reproduce
- Any relevant error messages
- Your Xcode and iOS versions
