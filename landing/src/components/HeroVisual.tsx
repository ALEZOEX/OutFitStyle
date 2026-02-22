import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CloudSun, CloudRain, Snowflake, Shirt, Briefcase, Coffee, Sparkles, Snowflake as SnowflakeIcon } from "lucide-react";

const OUTFITS = {
  office: {
    sun: { icon: Shirt, label: "Льняная рубашка", tag: "Smart Casual", color: "from-blue-400 to-indigo-500", temp: "24°C" },
    rain: { icon: Briefcase, label: "Тренч + Рубашка", tag: "Business", color: "from-slate-400 to-gray-500", temp: "15°C" },
    snow: { icon: Briefcase, label: "Шерстяное пальто", tag: "Winter Office", color: "from-slate-600 to-slate-800", temp: "-5°C" }
  },
  casual: {
    sun: { icon: Shirt, label: "Оверсайз футболка", tag: "Streetwear", color: "from-orange-400 to-rose-500", temp: "26°C" },
    rain: { icon: CloudRain, label: "Анорак + Джинсы", tag: "Gorpcore", color: "from-teal-400 to-emerald-500", temp: "14°C" },
    snow: { icon: SnowflakeIcon, label: "Пуховик", tag: "Cozy Winter", color: "from-cyan-400 to-blue-600", temp: "-10°C" }
  },
  date: {
    sun: { icon: Sparkles, label: "Лёгкое платье", tag: "Romantic", color: "from-pink-400 to-rose-500", temp: "22°C" },
    rain: { icon: Coffee, label: "Свитер крупной вязки", tag: "Cozy Date", color: "from-amber-400 to-orange-500", temp: "12°C" },
    snow: { icon: Sparkles, label: "Элегантное пальто", tag: "Evening", color: "from-violet-400 to-purple-600", temp: "-2°C" }
  }
} as const;

type Occasion = keyof typeof OUTFITS;
type Weather = keyof typeof OUTFITS[Occasion];

export function HeroVisual() {
  const [occasion, setOccasion] = useState<Occasion>("casual");
  const [weather, setWeather] = useState<Weather>("sun");

  const currentOutfit = OUTFITS[occasion][weather];
  const Icon = currentOutfit.icon;

  return (
    <div className="relative w-full max-w-lg mx-auto aspect-square flex items-center justify-center perspective-[1000px]">
      {/* Background Glow */}
      <motion.div 
        key={`${occasion}-${weather}-bg`}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1 }}
        className={`absolute inset-0 bg-gradient-to-tr ${currentOutfit.color} opacity-20 dark:opacity-10 rounded-full blur-[100px]`} 
      />

      {/* Interactive Main Glass Card */}
      <motion.div
        initial={{ y: 20, opacity: 0, rotateX: 10, rotateY: -10 }}
        animate={{ y: 0, opacity: 1, rotateX: 0, rotateY: 0 }}
        transition={{ duration: 1, type: "spring", stiffness: 100 }}
        className="relative z-20 w-80 h-[28rem] rounded-[2rem] bg-white/60 dark:bg-gray-800/60 backdrop-blur-2xl border border-white/80 dark:border-white/10 shadow-[0_20px_60px_-15px_rgba(0,0,0,0.1)] dark:shadow-[0_20px_60px_-15px_rgba(0,0,0,0.5)] p-6 flex flex-col hover:shadow-2xl transition-shadow duration-500"
      >
        {/* Controls */}
        <div className="flex justify-between items-center mb-6 gap-2 bg-white/50 dark:bg-gray-900/50 p-1.5 rounded-full border border-gray-200/50 dark:border-gray-700/50">
          {(['office', 'casual', 'date'] as const).map((o) => (
            <button
              key={o}
              onClick={() => setOccasion(o)}
              className={`flex-1 text-xs font-bold py-1.5 px-3 rounded-full transition-all duration-300 ${
                occasion === o 
                  ? 'bg-white dark:bg-gray-700 text-gray-900 dark:text-white shadow-sm scale-105' 
                  : 'text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
              }`}
            >
              {o === 'office' ? 'Офис' : o === 'casual' ? 'Кэжуал' : 'Свидание'}
            </button>
          ))}
        </div>
        
        <div className="flex-1 rounded-2xl bg-gray-50/50 dark:bg-gray-900/50 border border-gray-200/50 dark:border-gray-700/50 flex flex-col items-center justify-center p-6 relative overflow-hidden group">
            <div className={`absolute inset-0 bg-gradient-to-tr ${currentOutfit.color} opacity-0 group-hover:opacity-[0.05] transition-opacity duration-500`} />
            
            <AnimatePresence mode="wait">
              <motion.div 
                key={`${occasion}-${weather}-icon`}
                initial={{ scale: 0.5, opacity: 0, rotate: -20 }}
                animate={{ scale: 1, opacity: 1, rotate: 0 }}
                exit={{ scale: 0.5, opacity: 0, rotate: 20 }}
                transition={{ type: "spring", stiffness: 200, damping: 20 }}
                className="relative z-10"
              >
                <Icon className="w-28 h-28 text-gray-800 dark:text-gray-200 drop-shadow-2xl" strokeWidth={1} />
              </motion.div>
            </AnimatePresence>

            <AnimatePresence mode="wait">
              <motion.div 
                key={`${occasion}-${weather}-label`}
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                exit={{ y: -20, opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="mt-6 px-5 py-2.5 bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-full text-sm font-bold text-gray-800 dark:text-gray-100 border border-gray-200/50 dark:border-gray-700/50 shadow-lg"
              >
                {currentOutfit.label}
              </motion.div>
            </AnimatePresence>
        </div>
        
        <div className="mt-5 flex gap-2 items-center">
            <div className="h-2.5 flex-1 bg-gray-200/50 dark:bg-gray-700/50 rounded-full overflow-hidden">
                <motion.div 
                    key={`${occasion}-${weather}-bar`}
                    initial={{ width: "0%" }}
                    animate={{ width: "98%" }}
                    transition={{ duration: 1.5, type: "spring", bounce: 0.4 }}
                    className={`h-full bg-gradient-to-r ${currentOutfit.color}`}
                />
            </div>
            <span className="text-xs font-black text-gray-500 dark:text-gray-400 uppercase tracking-wider">98% Match</span>
        </div>
      </motion.div>

      {/* Interactive Weather Floating Card */}
      <motion.div
        initial={{ x: -50, y: 50, opacity: 0 }}
        animate={{ x: 0, y: 0, opacity: 1 }}
        transition={{ duration: 1, delay: 0.2, type: "spring" }}
        className="absolute top-16 -left-8 sm:-left-24 z-30 flex flex-col gap-2 bg-white/80 dark:bg-gray-800/80 backdrop-blur-2xl border border-white/50 dark:border-gray-700/50 rounded-3xl p-3 shadow-2xl"
      >
        <div className="text-xs font-bold text-gray-500 dark:text-gray-400 px-2 pb-1">Погода:</div>
        <div className="flex gap-2">
          {(['sun', 'rain', 'snow'] as const).map((w) => {
            const WIcon = w === 'sun' ? CloudSun : w === 'rain' ? CloudRain : Snowflake;
            return (
              <button
                key={w}
                onClick={() => setWeather(w)}
                className={`w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-300 ${
                  weather === w 
                    ? 'bg-blue-500 text-white shadow-lg scale-110' 
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-600'
                }`}
              >
                <WIcon className="w-6 h-6" />
              </button>
            );
          })}
        </div>
        <AnimatePresence mode="wait">
          <motion.div 
            key={`${occasion}-${weather}-temp`}
            initial={{ opacity: 0, y: -5 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 5 }}
            className="text-center font-black text-lg text-gray-900 dark:text-white mt-1"
          >
            {currentOutfit.temp}
          </motion.div>
        </AnimatePresence>
      </motion.div>

      {/* Style Tag Floating */}
      <motion.div
        initial={{ x: 50, y: -50, opacity: 0 }}
        animate={{ x: 0, y: 0, opacity: 1 }}
        transition={{ duration: 1, delay: 0.4, type: "spring" }}
        className="absolute bottom-24 -right-4 sm:-right-16 z-30 bg-white/80 dark:bg-gray-800/80 backdrop-blur-2xl border border-white/50 dark:border-gray-700/50 rounded-full px-6 py-4 shadow-2xl flex items-center gap-3"
      >
        <div className="relative flex h-3 w-3">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
          <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
        </div>
        <AnimatePresence mode="wait">
          <motion.span 
            key={`${occasion}-${weather}-tag`}
            initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 10 }}
            className="font-extrabold text-gray-800 dark:text-gray-200 tracking-wide"
          >
            {currentOutfit.tag}
          </motion.span>
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
