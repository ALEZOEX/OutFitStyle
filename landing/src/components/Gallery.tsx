import { motion } from "framer-motion";

const LOOKS = [
  { img: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=800", title: "Городской шик", tag: "Streetwear" },
  { img: "https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&q=80&w=800", title: "Минимализм", tag: "Business Casual" },
  { img: "https://images.unsplash.com/photo-1434389678232-01c0688a4e80?auto=format&fit=crop&q=80&w=800", title: "Выходные за городом", tag: "Casual" },
  { img: "https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&q=80&w=800", title: "Вечернее свидание", tag: "Elegant" },
];

export function Gallery() {
  return (
    <section className="py-32 px-4 sm:px-6 lg:px-8 relative z-10">
      <div className="max-w-7xl mx-auto">
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-extrabold text-gray-900 dark:text-white tracking-tight">Вдохновение</h2>
          <p className="mt-4 text-xl text-gray-600 dark:text-gray-400">Примеры образов, собранных нашей нейросетью.</p>
        </motion.div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {LOOKS.map((look, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ delay: i * 0.15, duration: 0.7, ease: "easeOut" }}
              className="group relative h-[28rem] rounded-3xl overflow-hidden cursor-pointer shadow-xl"
            >
              <img 
                src={look.img} 
                alt={look.title} 
                className="absolute inset-0 w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110" 
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#0f1115] via-[#0f1115]/40 to-transparent opacity-80 group-hover:opacity-90 transition-opacity duration-300" />
              
              <div className="absolute bottom-0 left-0 p-8 w-full transform translate-y-4 group-hover:translate-y-0 transition-transform duration-500">
                <span className="inline-block px-4 py-1.5 bg-white/20 backdrop-blur-md rounded-full text-xs font-bold text-white mb-3 tracking-wide uppercase shadow-lg">
                  {look.tag}
                </span>
                <h3 className="text-2xl font-extrabold text-white">{look.title}</h3>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
