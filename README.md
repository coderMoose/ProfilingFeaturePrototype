# README
### Demo
https://github.com/user-attachments/assets/759581d4-e109-4871-979a-763cb66848f2

This is a prototype of a feature that I’d like to see added to development tools to help beginners detect and understand CPU spikes while testing their apps.

### Description
Imagine a dev tool that would automatically record an xctrace for your test app whenever it detects 100% CPU usage.

It could then alert the developer about the CPU spike. 

*Sidenote: The alert would come in the form of the light bulb seen in the video, but please keep in mind that it should show up outside the test app's window. It's done this way for simplicity, but in reality, this project should be two different apps (the developer tool, and any app that the developer wants to test).*

After the alert, the dev tool would then prepare an AI-generated summary of the xctrace, containing the heaviest methods along with an explanation behind the spike.

A feature like this would make profiling more accessible to beginners who may not have used tools like Instruments before.

### Technical details
So how does this work technically? Let's go step by step:
- The 100% CPU button starts a for-loop that runs 1 million times, attempting to spike the CPU with print statements at every 100k interval.
- Once the button is pressed, an xctrace recording is started in the background by making a new Process(). The arguments passed to the process are as follows:
           [“xctrace",
            "record",
            "--attach", "\(pid)",
            "--template", "Time Profiler",
            "--time-limit", "2s",
            "--window", "100ms",
            "--output", outputURL.path]
- **Sidenote:** *The window parameter provides us with just enough samples to identify the hottest leaf nodes. I had to make the xctrace recording as small as possible to get through OpenAI’s API token limit.*
- Once the recording is complete, another Process() object is created to export the xctrace as an XML file using:
          ["xctrace",
            "export",
            "--input", tracePath,
            "--xpath", "/trace-toc/run[@number='1']/data/table[@schema='time-profile']",
            "--output", xmlTracePath]
- A light bulb is then displayed on the screen using SwiftUI. Once the user presses the light bulb icon, an API call to OpenAI is made with the XML file as raw text and the following prompt:
    
    I have an Apple Instruments XML file from a Time Profiler trace. I want to find the hottest frames and call paths. Please do the following:
    1. Parse the XML file and locate all <row> entries in the time-profile table.
    2. For each row, resolve the backtrace to its sequence of frames.
    3. Count:
       - The total number of samples.
       - The occurrences of each frame anywhere in the backtrace (inclusive).
       - The occurrences of the leaf (deepest) frame in each backtrace.
       - The occurrences of exact stack paths (leaf → ... → root).
       - The occurrences of leaf-up prefixes (partial paths).
    4. Output the **heaviest leaf frames**, showing:
       - Frame name
       - Number of samples it appears as the leaf
       - Percentage of total samples
    5. Please provide the output in a concise, readable text table including the heaviest leaf frames and their weight. Only reply with that table (a.k.a only reply with step 5 but still do step 4, etc...). Include one sentence explaining what the hottest leaf node is caused by (a button? an HTTP request? etc...)

- Finally, the AI’s answer is decoded as a string and displayed in AnalyserView().

### Next Steps:
- Find a better way to send the xctrace’s XML to ChatGPT.
    - It seems XML files aren’t supported by OpenAI’s free tier API, but perhaps the Batch or Assistant modes would have more file options.

- Better explanations from the AI summary and better formating for the AI response.
- A way to find the exact view OR line of code that caused the CPU spike (could be identified from the stack trace of the heaviest leaf node).

Had a lot of fun building this through trial and error and a bit of vibe coding :)
