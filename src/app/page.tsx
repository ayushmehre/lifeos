"use client";

import { useState, useRef, useEffect } from "react";
import {
	Send,
	Bot,
	User,
	Loader2,
	MessageSquare,
	FolderOpen,
	Plus,
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
	const [showAddDialog, setShowAddDialog] = useState(false);
	const [newContextName, setNewContextName] = useState("");
	const [newContextDescription, setNewContextDescription] = useState("");
	const [messages, setMessages] = useState<Message[]>([]);
	const [contexts, setContexts] = useState<Context[]>([
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
	const messagesEndRef = useRef<HTMLDivElement>(null);
	const inputRef = useRef<HTMLTextAreaElement>(null);

	const scrollToBottom = () => {
		messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
	};

	useEffect(() => {
		scrollToBottom();
	}, [messages]);

	// Add initial welcome message after component mounts
	useEffect(() => {
		if (messages.length === 0) {
			setMessages([
				{
					id: "1",
					content: "Hello! I'm your AI assistant. How can I help you today?",
					role: "assistant",
					timestamp: new Date(),
				},
			]);
		}
	}, [messages.length]);

	// PWA install prompt and service worker registration removed

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

	// PWA install handlers removed

	const handleAddContext = () => {
		if (!newContextName.trim()) return;

		const newContext: Context = {
			id: Date.now().toString(),
			name: newContextName.trim().toLowerCase().replace(/\s+/g, "-"),
			description: newContextDescription.trim() || "No description",
			lastUpdated: new Date(),
		};

		setContexts((prev) => [newContext, ...prev]);
		setNewContextName("");
		setNewContextDescription("");
		setShowAddDialog(false);
	};

	const handleCancelAdd = () => {
		setNewContextName("");
		setNewContextDescription("");
		setShowAddDialog(false);
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

	const formatTime = (date: Date) => {
		// Use a consistent format that doesn't depend on locale
		const hours = date.getHours();
		const minutes = date.getMinutes();
		const ampm = hours >= 12 ? "PM" : "AM";
		const displayHours = hours % 12 || 12;
		const displayMinutes = minutes.toString().padStart(2, "0");
		return `${displayHours}:${displayMinutes} ${ampm}`;
	};

	return (
		<div className="flex flex-col h-screen bg-[#1A1D21]">
			{/* Header */}
			<header className="flex items-center justify-between p-3 border-b border-[#3D4043] bg-gradient-to-r from-[#3F0E40] to-[#611F69]">
				<div className="flex items-center space-x-2">
					<div className="w-8 h-8 bg-gradient-to-r from-[#36C5F0] to-[#2EB67D] rounded-lg flex items-center justify-center">
						<Bot className="w-5 h-5 text-white" />
					</div>
					<h1 className="text-[15px] font-semibold text-white">
						LifeOS
					</h1>
				</div>
				<div className="text-[13px] text-white/70">
					{activeTab === "contexts" ? "Contexts" : "AI Assistant"}
				</div>
			</header>

			{/* Main Content */}
			<div className="flex-1 overflow-hidden">
				{activeTab === "contexts" ? (
					<div className="h-full overflow-y-auto">
						{/* Add Button */}
						<div className="px-4 py-3 border-b border-[#3D4043]">
							<button
								onClick={() => setShowAddDialog(true)}
								className="w-full flex items-center justify-center space-x-2 px-4 py-2 bg-[#36C5F0] hover:bg-[#1D9BD1] text-white rounded-lg transition-colors"
							>
								<Plus className="w-4 h-4" />
								<span className="text-sm font-medium">Add Context</span>
							</button>
						</div>
						<div className="py-2">
							{contexts.map((context) => (
								<div
									key={context.id}
									className="px-4 py-2 hover:bg-[#222529] transition-colors cursor-pointer flex items-center justify-between"
								>
									<div className="flex items-center space-x-3">
										<div className="w-2 h-2 bg-[#9AA1A9] rounded-full"></div>
										<div>
											<h3 className="font-medium text-[#EDEDED] text-[13px]">
												#{context.name}
											</h3>
											<p className="text-[12px] text-[#9AA1A9]">
												{formatDate(context.lastUpdated)}
											</p>
										</div>
									</div>
									<div className="text-[12px] text-[#9AA1A9]">
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
						<div className="flex-1 overflow-y-auto p-3 space-y-3">
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
												message.role === "user" ? "bg-[#36C5F0]" : "bg-[#3D4043]"
											}`}
										>
											{message.role === "user" ? (
												<User className="w-4 h-4 text-white" />
											) : (
												<Bot className="w-4 h-4 text-[#EDEDED]" />
											)}
										</div>
										<div
											className="px-4 py-2 rounded-2xl bg-[#222529] text-[#EDEDED] border border-[#3D4043]"
										>
											<p className="text-sm whitespace-pre-wrap">
												{message.content}
											</p>
											<p
												className="text-[12px] mt-1 text-[#9AA1A9]"
											>
												{formatTime(message.timestamp)}
											</p>
										</div>
									</div>
								</div>
							))}

							{/* Loading indicator */}
							{isLoading && (
								<div className="flex justify-start">
									<div className="flex space-x-2">
										<div className="w-8 h-8 rounded-full bg-[#3D4043] flex items-center justify-center">
											<Bot className="w-4 h-4 text-[#EDEDED]" />
										</div>
										<div className="px-4 py-2 rounded-2xl bg-[#222529] border border-[#3D4043]">
											<div className="flex items-center space-x-2">
												<Loader2 className="w-4 h-4 animate-spin text-[#9AA1A9]" />
												<span className="text-sm text-[#9AA1A9]">
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
						<div className="border-t border-[#3D4043] bg-[#1A1D21] p-3">
							<form onSubmit={handleSubmit} className="flex space-x-4">
								<div className="flex-1 relative">
									<textarea
										ref={inputRef}
										value={inputValue}
										onChange={handleTextareaChange}
										onKeyDown={handleKeyDown}
										placeholder="Type your message here..."
										className="w-full px-4 py-3 border border-[#3D4043] rounded-md resize-none focus:outline-none focus:ring-2 focus:ring-[#36C5F0] focus:border-transparent bg-[#222529] text-[#EDEDED] placeholder-[#9AA1A9]"
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
									className="px-4 py-3 bg-[#36C5F0] hover:bg-[#1D9BD1] disabled:bg-[#3D4043] text-white rounded-md transition-colors duration-200 flex items-center justify-center disabled:cursor-not-allowed"
								>
									<Send className="w-5 h-5" />
								</button>
							</form>
							<p className="text-[12px] text-[#9AA1A9] mt-2 text-center">
								Press Enter to send, Shift+Enter for new line
							</p>
						</div>
					</div>
				)}
			</div>

			{/* Bottom Tab Navigation */}
			<div className="border-t border-[#3D4043] bg-[#1A1D21]">
				<div className="flex">
					<button
						onClick={() => setActiveTab("contexts")}
						className={`flex-1 flex flex-col items-center py-3 px-2 transition-colors ${
							activeTab === "contexts"
								? "text-[#36C5F0]"
								: "text-[#9AA1A9] hover:text-[#EDEDED]"
						}`}
					>
						<FolderOpen className="w-5 h-5 mb-1" />
						<span className="text-xs font-medium">Contexts</span>
					</button>
					<button
						onClick={() => setActiveTab("chat")}
						className={`flex-1 flex flex-col items-center py-3 px-2 transition-colors ${
							activeTab === "chat"
								? "text-[#36C5F0]"
								: "text-[#9AA1A9] hover:text-[#EDEDED]"
						}`}
					>
						<MessageSquare className="w-5 h-5 mb-1" />
						<span className="text-xs font-medium">Chat</span>
					</button>
				</div>
			</div>

			{/* Add Context Dialog */}
			{showAddDialog && (
				<div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
					<div className="bg-[#222529] rounded-lg shadow-xl w-full max-w-md border border-[#3D4043]">
						<div className="p-6">
							<h3 className="text-lg font-semibold text-[#EDEDED] mb-4">
								Create New Context
							</h3>
							<div className="space-y-4">
								<div>
									<label className="block text-sm font-medium text-[#EDEDED] mb-2">
										Context Name
									</label>
									<input
										type="text"
										value={newContextName}
										onChange={(e) => setNewContextName(e.target.value)}
										placeholder="e.g., project-name"
										className="w-full px-3 py-2 border border-[#3D4043] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#36C5F0] focus:border-transparent bg-[#1A1D21] text-[#EDEDED] placeholder-[#9AA1A9]"
										autoFocus
									/>
								</div>
								<div>
									<label className="block text-sm font-medium text-[#EDEDED] mb-2">
										Description (optional)
									</label>
									<textarea
										value={newContextDescription}
										onChange={(e) => setNewContextDescription(e.target.value)}
										placeholder="Brief description of this context"
										rows={3}
										className="w-full px-3 py-2 border border-[#3D4043] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#36C5F0] focus:border-transparent bg-[#1A1D21] text-[#EDEDED] placeholder-[#9AA1A9] resize-none"
									/>
								</div>
							</div>
							<div className="flex space-x-3 mt-6">
								<button
									onClick={handleCancelAdd}
									className="flex-1 px-4 py-2 border border-[#3D4043] text-[#EDEDED] rounded-lg hover:bg-[#222529] transition-colors"
								>
									Cancel
								</button>
								<button
									onClick={handleAddContext}
									disabled={!newContextName.trim()}
									className="flex-1 px-4 py-2 bg-[#36C5F0] hover:bg-[#1D9BD1] disabled:bg-[#3D4043] text-white rounded-lg transition-colors disabled:cursor-not-allowed"
								>
									Create
								</button>
							</div>
						</div>
					</div>
				</div>
			)}

			{/* PWA Install Prompt removed */}
		</div>
	);
}
