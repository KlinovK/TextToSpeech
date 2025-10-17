# SpeechToText AI

A futuristic iOS app that transforms your **voice into intelligent AI conversations**. Built entirely with **SwiftUI** and a custom implementation of the **TCA (The Composable Architecture)** pattern for a clean, reactive, and testable structure. The app leverages **Apple’s Speech framework** for on-device transcription and integrates with **local LLMs via Ollama**, enabling private, offline-friendly AI chat.  

Featuring a **glassmorphic, AI-inspired interface** with smooth animations, glowing chat bubbles, and real-time recording feedback, VOICECHAT AI brings a conversational AI experience to your fingertips — powered by your own voice.

---

## Key Features

- 🎙️ **Voice Recognition:**  
  Convert speech to text in real time using Apple’s Speech framework.

- 🤖 **Local AI Chat:**  
  Communicate with an LLM (like Llama or Phi) through Ollama’s local inference server — no cloud APIs required.

- 🧠 **Composable Architecture (TCA):**  
  A fully custom, dependency-free TCA setup for predictable state management and clear separation of concerns.

- 💬 **Futuristic Chat UI:**  
  Elegant, glassmorphic chat bubbles with dynamic gradients and smooth scrolling animations.

- ⚡ **Private & Offline-Friendly:**  
  All speech processing and AI inference occur locally — your data stays on your device.

---

## Architecture

VOICECHAT AI follows the **TCA (The Composable Architecture)** pattern with a clean separation between state, actions, and environment dependencies.

### Layered Structure

- **View Layer (SwiftUI)**  
  Handles UI rendering, animations, and reactive bindings to app state.

- **Reducer Layer**  
  Defines all user interactions, state transitions, and side effects like speech recognition and AI calls.

- **Environment Layer**  
  Manages dependencies including the speech recognizer and Ollama network client.

---

## Getting Started

### Prerequisites

- **Xcode 16+**  
- **iOS 17.0+**  
- **Swift 5.9+**  
- **Ollama (running locally)**  
  Download and install from [ollama.com](https://ollama.com), then start the server:
  ```bash
  ollama serve
