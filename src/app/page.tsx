"use client";

import { useState, useRef, useEffect } from "react";
import {
	Send,
	Bot,
	User,
	Loader2,
	Download,
	X,
	MessageSquare,
	FolderOpen,
} from "lucide-react";

interface Message {
	id: string;
	content: string;
	role: "user" | "assistant";
	timestamp: Date;
}

interface Context {
	id: string;
	name: string;
	description: string;
	lastUpdated: Date;
}

export default function Home() {
	const [activeTab, setActiveTab] = useState<"contexts" | "chat">("chat");
	const [messages, setMessages] = useState<Message[]>([
		{
			id: "1",
			content: "Hello! I'm your AI assistant. How can I help you today?",
			role: "assistant",
			timestamp: new Date(),
		},
	]);
	const [contexts] = useState<Context[]>([
		{
			id: "1",
			name: "general",
			description: "General discussions and announcements",
			lastUpdated: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
		},
		{
			id: "2",
			name: "work-projects",
			description: "Work-related projects and tasks",
			lastUpdated: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
		},
		{
			id: "3",
			name: "personal-goals",
			description: "Personal development and goal setting",
			lastUpdated: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
		},
		{
			id: "4",
			name: "learning",
			description: "Study materials and learning discussions",
			lastUpdated: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
		},
		{
			id: "5",
			name: "random",
			description: "Random thoughts and casual conversations",
			lastUpdated: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000), // 4 days ago
		},
	]);
	const [inputValue, setInputValue] = useState("");
	const [isLoading, setIsLoading] = useState(false);
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
	const [showInstallPrompt, setShowInstallPrompt] = useState(false);
	const messagesEndRef = useRef<HTMLDivElement>(null);
	const inputRef = useRef<HTMLTextAreaElement>(null);

	const scrollToBottom = () => {
		messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
	};

	useEffect(() => {
		scrollToBottom();
	}, [messages]);

	useEffect(() => {
		const handler = (e: Event) => {
			e.preventDefault();
			setDeferredPrompt(e);
			setShowInstallPrompt(true);
		};

		window.addEventListener("beforeinstallprompt", handler);

		// Register service worker
		if ("serviceWorker" in navigator) {
			navigator.serviceWorker
				.register("/sw.js")
				.then((registration) => {
					console.log("SW registered: ", registration);
				})
				.catch((registrationError) => {
					console.log("SW registration failed: ", registrationError);
				});
		}

		return () => {
			window.removeEventListener("beforeinstallprompt", handler);
		};
	}, []);

	const handleSubmit = async (e: React.FormEvent) => {
		e.preventDefault();
		if (!inputValue.trim() || isLoading) return;

		const userMessage: Message = {
			id: Date.now().toString(),
			content: inputValue.trim(),
			role: "user",
			timestamp: new Date(),
		};

		setMessages((prev) => [...prev, userMessage]);
		setInputValue("");
		setIsLoading(true);

		// Simulate AI response (replace with actual API call)
		setTimeout(() => {
			const aiMessage: Message = {
				id: (Date.now() + 1).toString(),
				content: `I received your message: "${userMessage.content}". This is a simulated response. In a real application, you would integrate with an AI API here.`,
				role: "assistant",
				timestamp: new Date(),
			};
			setMessages((prev) => [...prev, aiMessage]);
			setIsLoading(false);
		}, 1000);
	};

	const handleKeyDown = (e: React.KeyboardEvent) => {
		if (e.key === "Enter" && !e.shiftKey) {
			e.preventDefault();
			handleSubmit(e);
		}
	};

	const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
		setInputValue(e.target.value);

		// Auto-resize textarea
		const textarea = e.target;
		textarea.style.height = "auto";
		textarea.style.height = Math.min(textarea.scrollHeight, 120) + "px";
	};

	const handleInstallClick = async () => {
		if (!deferredPrompt) return;

		deferredPrompt.prompt();
		const { outcome } = await deferredPrompt.userChoice;

		if (outcome === "accepted") {
			console.log("User accepted the install prompt");
		} else {
			console.log("User dismissed the install prompt");
		}

		setDeferredPrompt(null);
		setShowInstallPrompt(false);
	};

	const handleDismissInstall = () => {
		setShowInstallPrompt(false);
	};

	const formatDate = (date: Date) => {
		const now = new Date();
		const diffInHours = Math.floor(
			(now.getTime() - date.getTime()) / (1000 * 60 * 60)
		);

		if (diffInHours < 1) return "Just now";
		if (diffInHours < 24) return `${diffInHours}h ago`;
		if (diffInHours < 48) return "Yesterday";
		return date.toLocaleDateString();
	};

	return (
		<div className="flex flex-col h-screen bg-gray-50 dark:bg-gray-900">
			{/* Header */}
			<header className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800">
				<div className="flex items-center space-x-2">
					<div className="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
						<Bot className="w-5 h-5 text-white" />
					</div>
					<h1 className="text-xl font-semibold text-gray-900 dark:text-white">
						LifeOS
					</h1>
				</div>
				<div className="text-sm text-gray-500 dark:text-gray-400">
					{activeTab === "contexts" ? "Contexts" : "AI Assistant"}
				</div>
			</header>

			{/* Main Content */}
			<div className="flex-1 overflow-hidden">
				{activeTab === "contexts" ? (
					<div className="h-full overflow-y-auto">
						<div className="py-2">
							{contexts.map((context) => (
								<div
									key={context.id}
									className="px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors cursor-pointer flex items-center justify-between"
								>
									<div className="flex items-center space-x-3">
										<div className="w-2 h-2 bg-gray-400 rounded-full"></div>
										<div>
											<h3 className="font-medium text-gray-900 dark:text-white text-sm">
												#{context.name}
											</h3>
											<p className="text-xs text-gray-500 dark:text-gray-400">
												{formatDate(context.lastUpdated)}
											</p>
										</div>
									</div>
									<div className="text-xs text-gray-400">
										{context.description.length > 30
											? `${context.description.substring(0, 30)}...`
											: context.description}
									</div>
								</div>
							))}
						</div>
					</div>
				) : (
					<div className="h-full flex flex-col">
						{/* Messages Container */}
						<div className="flex-1 overflow-y-auto p-4 space-y-4">
							{messages.map((message) => (
								<div
									key={message.id}
									className={`flex ${
										message.role === "user" ? "justify-end" : "justify-start"
									}`}
								>
									<div
										className={`flex max-w-[80%] space-x-2 ${
											message.role === "user"
												? "flex-row-reverse space-x-reverse"
												: ""
										}`}
									>
										<div
											className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
												message.role === "user"
													? "bg-blue-500"
													: "bg-gray-200 dark:bg-gray-700"
											}`}
										>
											{message.role === "user" ? (
												<User className="w-4 h-4 text-white" />
											) : (
												<Bot className="w-4 h-4 text-gray-600 dark:text-gray-300" />
											)}
										</div>
										<div
											className={`px-4 py-2 rounded-2xl ${
												message.role === "user"
													? "bg-blue-500 text-white"
													: "bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700"
											}`}
										>
											<p className="text-sm whitespace-pre-wrap">
												{message.content}
											</p>
											<p
												className={`text-xs mt-1 ${
													message.role === "user"
														? "text-blue-100"
														: "text-gray-500 dark:text-gray-400"
												}`}
											>
												{message.timestamp.toLocaleTimeString([], {
													hour: "2-digit",
													minute: "2-digit",
												})}
											</p>
										</div>
									</div>
								</div>
							))}

							{/* Loading indicator */}
							{isLoading && (
								<div className="flex justify-start">
									<div className="flex space-x-2">
										<div className="w-8 h-8 rounded-full bg-gray-200 dark:bg-gray-700 flex items-center justify-center">
											<Bot className="w-4 h-4 text-gray-600 dark:text-gray-300" />
										</div>
										<div className="px-4 py-2 rounded-2xl bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700">
											<div className="flex items-center space-x-2">
												<Loader2 className="w-4 h-4 animate-spin text-gray-500" />
												<span className="text-sm text-gray-500">
													AI is thinking...
												</span>
											</div>
										</div>
									</div>
								</div>
							)}

							<div ref={messagesEndRef} />
						</div>

						{/* Input Area */}
						<div className="border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4">
							<form onSubmit={handleSubmit} className="flex space-x-4">
								<div className="flex-1 relative">
									<textarea
										ref={inputRef}
										value={inputValue}
										onChange={handleTextareaChange}
										onKeyDown={handleKeyDown}
										placeholder="Type your message here..."
										className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-2xl resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400"
										rows={1}
										style={{
											minHeight: "48px",
											maxHeight: "120px",
										}}
										autoComplete="off"
										autoCorrect="off"
										autoCapitalize="off"
										spellCheck="false"
									/>
								</div>
								<button
									type="submit"
									disabled={!inputValue.trim() || isLoading}
									className="px-4 py-3 bg-blue-500 hover:bg-blue-600 disabled:bg-gray-300 dark:disabled:bg-gray-600 text-white rounded-2xl transition-colors duration-200 flex items-center justify-center disabled:cursor-not-allowed"
								>
									<Send className="w-5 h-5" />
								</button>
							</form>
							<p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
								Press Enter to send, Shift+Enter for new line
							</p>
						</div>
					</div>
				)}
			</div>

			{/* Bottom Tab Navigation */}
			<div className="border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800">
				<div className="flex">
					<button
						onClick={() => setActiveTab("contexts")}
						className={`flex-1 flex flex-col items-center py-3 px-2 transition-colors ${
							activeTab === "contexts"
								? "text-blue-500 bg-blue-50 dark:bg-blue-900/20"
								: "text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
						}`}
					>
						<FolderOpen className="w-5 h-5 mb-1" />
						<span className="text-xs font-medium">Contexts</span>
					</button>
					<button
						onClick={() => setActiveTab("chat")}
						className={`flex-1 flex flex-col items-center py-3 px-2 transition-colors ${
							activeTab === "chat"
								? "text-blue-500 bg-blue-50 dark:bg-blue-900/20"
								: "text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
						}`}
					>
						<MessageSquare className="w-5 h-5 mb-1" />
						<span className="text-xs font-medium">Chat</span>
					</button>
				</div>
			</div>

			{/* PWA Install Prompt */}
			{showInstallPrompt && (
				<div className="fixed bottom-20 left-4 right-4 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg p-4 z-50">
					<div className="flex items-center justify-between">
						<div className="flex items-center space-x-3">
							<div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
								<Download className="w-5 h-5 text-white" />
							</div>
							<div>
								<h3 className="text-sm font-semibold text-gray-900 dark:text-white">
									Install LifeOS Chat
								</h3>
								<p className="text-xs text-gray-500 dark:text-gray-400">
									Add to home screen for quick access
								</p>
							</div>
						</div>
						<div className="flex items-center space-x-2">
							<button
								onClick={handleInstallClick}
								className="px-3 py-1.5 bg-blue-500 hover:bg-blue-600 text-white text-xs font-medium rounded-md transition-colors"
							>
								Install
							</button>
							<button
								onClick={handleDismissInstall}
								className="p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
							>
								<X className="w-4 h-4" />
							</button>
						</div>
					</div>
				</div>
			)}
		</div>
	);
}
