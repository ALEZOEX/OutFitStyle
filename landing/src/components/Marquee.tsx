import { motion } from "framer-motion";

const TAGS = [
  "Streetwear", "Smart Casual", "Old Money", "Y2K", "Gorpcore",
  "Minimalism", "Business", "Sport Chic", "Vintage", "Boho",
  "Techwear", "Cyberpunk", "Preppy", "Grunge", "Avant-Garde"
];

export function Marquee() {
  return (
    <div className="w-full overflow-hidden py-10 relative z-10 bg-white/30 dark:bg-[#0a0c10]/30 border-y border-gray-200/50 dark:border-gray-800/50 backdrop-blur-sm mt-12 mb-12 flex">
      <motion.div
        className="flex whitespace-nowrap gap-8 pr-8"
        animate={{ x: [0, -1000] }}
        transition={{ repeat: Infinity, duration: 25, ease: "linear" }}
      >
        {[...TAGS, ...TAGS, ...TAGS].map((tag, i) => (
          <div 
            key={i} 
            className="px-6 py-2 rounded-full border border-gray-300 dark:border-gray-700 bg-white/50 dark:bg-gray-800/50 text-gray-700 dark:text-gray-300 text-sm font-semibold tracking-wider uppercase shadow-sm flex items-center gap-2"
          >
            <span className="w-2 h-2 rounded-full bg-primary-500" />
            {tag}
          </div>
        ))}
      </motion.div>
      <div className="absolute inset-y-0 left-0 w-32 bg-gradient-to-r from-white dark:from-[#0f1115] to-transparent z-10 pointer-events-none" />
      <div className="absolute inset-y-0 right-0 w-32 bg-gradient-to-l from-white dark:from-[#0f1115] to-transparent z-10 pointer-events-none" />
    </div>
  );
}
