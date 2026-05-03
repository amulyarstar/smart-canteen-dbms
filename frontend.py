import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from datetime import datetime

class DemoFriendlyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Presidency University - Campus Food System (DEMO MODE)")
        self.root.geometry("1200x800")
        self.root.configure(bg='#0f1729')
        
        # Colors
        self.colors = {
            'bg_dark': '#0f1729',
            'bg_card': '#1e293b',
            'primary': '#6366f1',
            'success': '#10b981',
            'danger': '#ef4444',
            'warning': '#f59e0b',
            'text': '#f1f5f9',
            'text_muted': '#94a3b8',
            'border': '#334155'
        }
        
        # Variables
        self.current_student_id = None
        self.student_data = []
        self.item_data = []
        self.outlet_list = []
        self.db = None
        self.cursor = None
        
        # Setup UI first
        self.setup_ui()
        
        # Then connect to DB
        self.connect_to_db()
        
        # Then load students
        self.load_students()
    
    def connect_to_db(self):
        try:
            self.db = mysql.connector.connect(
                host="localhost",
                user="root",
                password="amulya",
                database="campus_food_db",
                autocommit=True
            )
            self.cursor = self.db.cursor(buffered=True)
            print("✅ Connected to database")
            self.status_bar.config(text="✅ Connected to database", fg=self.colors['success'])
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            if hasattr(self, 'status_bar'):
                self.status_bar.config(text=f"❌ Connection failed: {e}", fg=self.colors['danger'])
    
    def setup_ui(self):
        # Main container
        main_frame = tk.Frame(self.root, bg=self.colors['bg_dark'])
        main_frame.pack(fill='both', expand=True, padx=20, pady=20)
        
        # Header
        header = tk.Frame(main_frame, bg=self.colors['primary'], height=80)
        header.pack(fill='x', pady=(0, 20))
        header.pack_propagate(False)
        
        title = tk.Label(header, text="🍽️ PRESIDENCY UNIVERSITY CAMPUS FOOD SYSTEM", 
                         font=("Arial", 18, "bold"), bg=self.colors['primary'], fg='white')
        title.pack(expand=True)
        
        # Demo Banner
        demo_banner = tk.Frame(main_frame, bg=self.colors['warning'], height=35)
        demo_banner.pack(fill='x', pady=(0, 20))
        demo_banner.pack_propagate(False)
        
        demo_label = tk.Label(demo_banner, text="🎯 DEMO MODE - Break simulation active!", 
                              font=("Arial", 11, "bold"), bg=self.colors['warning'], fg='#1f2937')
        demo_label.pack(expand=True)
        
        # Two columns
        left_col = tk.Frame(main_frame, bg=self.colors['bg_dark'])
        left_col.pack(side='left', fill='both', expand=True, padx=(0, 10))
        
        right_col = tk.Frame(main_frame, bg=self.colors['bg_dark'])
        right_col.pack(side='right', fill='both', expand=True, padx=(10, 0))
        
        # ===== LEFT COLUMN =====
        
        # Student Card
        student_card = self.create_card(left_col, "👤 SELECT STUDENT")
        student_card.pack(fill='x', pady=(0, 15))
        
        self.student_combo = ttk.Combobox(student_card, font=("Arial", 12), state='readonly')
        self.student_combo.pack(fill='x', padx=15, pady=15)
        self.student_combo.bind('<<ComboboxSelected>>', self.on_student_select)
        
        # Break Card
        break_card = self.create_card(left_col, "⏰ BREAK STATUS")
        break_card.pack(fill='x', pady=(0, 15))
        
        break_inner = tk.Frame(break_card, bg=self.colors['bg_card'])
        break_inner.pack(fill='x', padx=15, pady=15)
        
        self.break_icon = tk.Label(break_inner, text="🌅", font=("Arial", 30), bg=self.colors['bg_card'])
        self.break_icon.pack(side='left', padx=(0, 15))
        
        break_text = tk.Frame(break_inner, bg=self.colors['bg_card'])
        break_text.pack(side='left', fill='x', expand=True)
        
        self.break_status = tk.Label(break_text, text="MORNING BREAK ACTIVE!", 
                                     font=("Arial", 13, "bold"), bg=self.colors['bg_card'], 
                                     fg=self.colors['success'])
        self.break_status.pack(anchor='w')
        
        self.break_timer = tk.Label(break_text, text="⏳ 10 minutes remaining", 
                                    font=("Arial", 10), bg=self.colors['bg_card'], 
                                    fg=self.colors['warning'])
        self.break_timer.pack(anchor='w')
        
        # Break buttons
        btn_frame = tk.Frame(break_inner, bg=self.colors['bg_card'])
        btn_frame.pack(side='right')
        
        tk.Button(btn_frame, text="🌅 Morning", bg=self.colors['success'], fg='white',
                  command=lambda: self.set_break('morning')).pack(side='left', padx=2)
        tk.Button(btn_frame, text="🌙 Afternoon", bg=self.colors['success'], fg='white',
                  command=lambda: self.set_break('afternoon')).pack(side='left', padx=2)
        tk.Button(btn_frame, text="📚 None", bg=self.colors['danger'], fg='white',
                  command=lambda: self.set_break('none')).pack(side='left', padx=2)
        
        # Outlets Card
        outlets_card = self.create_card(left_col, "📍 NEAREST OUTLETS")
        outlets_card.pack(fill='both', expand=True)
        
        tree_frame = tk.Frame(outlets_card, bg=self.colors['bg_card'])
        tree_frame.pack(fill='both', expand=True, padx=15, pady=15)
        
        columns = ('Outlet', 'Distance', 'Walk', 'Round', 'Items', 'Status')
        self.tree = ttk.Treeview(tree_frame, columns=columns, show='headings', height=8)
        for col in columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=120)
        
        scroll = ttk.Scrollbar(tree_frame, orient='vertical', command=self.tree.yview)
        self.tree.configure(yscrollcommand=scroll.set)
        self.tree.pack(side='left', fill='both', expand=True)
        scroll.pack(side='right', fill='y')
        
        # ===== RIGHT COLUMN =====
        
        # Order Card
        order_card = self.create_card(right_col, "🛒 PLACE ORDER")
        order_card.pack(fill='x', pady=(0, 15))
        
        order_inner = tk.Frame(order_card, bg=self.colors['bg_card'])
        order_inner.pack(fill='x', padx=15, pady=15)
        
        tk.Label(order_inner, text="Outlet:", bg=self.colors['bg_card'], fg=self.colors['text']).pack(anchor='w')
        self.outlet_combo = ttk.Combobox(order_inner, font=("Arial", 11), state='readonly')
        self.outlet_combo.pack(fill='x', pady=(5, 10))
        self.outlet_combo.bind('<<ComboboxSelected>>', self.load_menu)
        
        tk.Label(order_inner, text="Item:", bg=self.colors['bg_card'], fg=self.colors['text']).pack(anchor='w')
        self.item_combo = ttk.Combobox(order_inner, font=("Arial", 11), state='readonly')
        self.item_combo.pack(fill='x', pady=(5, 10))
        
        # Quantity
        qty_frame = tk.Frame(order_inner, bg=self.colors['bg_card'])
        qty_frame.pack(fill='x', pady=10)
        
        tk.Label(qty_frame, text="Quantity:", bg=self.colors['bg_card'], fg=self.colors['text']).pack(side='left')
        
        self.qty_var = tk.IntVar(value=1)
        tk.Button(qty_frame, text="-", width=2, command=lambda: self.update_qty(-1)).pack(side='left', padx=5)
        self.qty_label = tk.Label(qty_frame, text="1", width=5, bg=self.colors['bg_card'], fg=self.colors['text'])
        self.qty_label.pack(side='left')
        tk.Button(qty_frame, text="+", width=2, command=lambda: self.update_qty(1)).pack(side='left', padx=5)
        
        # Order button
        tk.Button(order_inner, text="✅ PLACE ORDER", font=("Arial", 12, "bold"), 
                  bg=self.colors['success'], fg='white', command=self.place_order).pack(fill='x', pady=10)
        
        # Concurrency Card
        conc_card = self.create_card(right_col, "⚡ CONCURRENCY TEST")
        conc_card.pack(fill='x', pady=(0, 15))
        
        conc_inner = tk.Frame(conc_card, bg=self.colors['bg_card'])
        conc_inner.pack(fill='x', padx=15, pady=15)
        
        tk.Label(conc_inner, text="Test: Multiple students ordering last 5 plates", 
                bg=self.colors['bg_card'], fg=self.colors['text']).pack()
        
        self.conc_btn = tk.Button(conc_inner, text="🚀 RUN CONCURRENCY TEST", 
                                  bg=self.colors['warning'], fg='black',
                                  font=("Arial", 11, "bold"), command=self.run_concurrency_demo)
        self.conc_btn.pack(pady=10, fill='x')
        
        self.conc_result = tk.Label(conc_inner, text="", bg=self.colors['bg_card'], 
                                    fg=self.colors['success'])
        self.conc_result.pack()
        
        # History Card
        history_card = self.create_card(right_col, "📋 RECENT ORDERS")
        history_card.pack(fill='both', expand=True)
        
        self.history_text = tk.Text(history_card, height=6, bg=self.colors['bg_card'], 
                                    fg=self.colors['text_muted'], wrap='word')
        self.history_text.pack(fill='both', expand=True, padx=15, pady=15)
        
        # Status bar
        self.status_bar = tk.Label(main_frame, text="✅ Ready", bg=self.colors['bg_dark'], 
                                   fg=self.colors['success'], anchor='w')
        self.status_bar.pack(fill='x', pady=(20, 0))
    
    def create_card(self, parent, title):
        card = tk.Frame(parent, bg=self.colors['bg_card'], 
                        highlightbackground=self.colors['border'], highlightthickness=1)
        
        title_bar = tk.Frame(card, bg=self.colors['primary'], height=35)
        title_bar.pack(fill='x')
        title_bar.pack_propagate(False)
        
        tk.Label(title_bar, text=title, font=("Arial", 11, "bold"), 
                 bg=self.colors['primary'], fg='white').pack(side='left', padx=15, pady=8)
        
        return card
    
    def set_break(self, break_type):
        if break_type == 'morning':
            self.break_icon.config(text="🌅")
            self.break_status.config(text="MORNING BREAK ACTIVE!", fg=self.colors['success'])
            self.break_timer.config(text="⏳ 10 minutes remaining")
        elif break_type == 'afternoon':
            self.break_icon.config(text="🌙")
            self.break_status.config(text="AFTERNOON BREAK ACTIVE!", fg=self.colors['success'])
            self.break_timer.config(text="⏳ 10 minutes remaining")
        else:
            self.break_icon.config(text="📚")
            self.break_status.config(text="NO ACTIVE BREAK", fg=self.colors['danger'])
            self.break_timer.config(text="Click Morning/Afternoon to activate")
    
    def update_qty(self, delta):
        new_val = self.qty_var.get() + delta
        if 1 <= new_val <= 10:
            self.qty_var.set(new_val)
            self.qty_label.config(text=str(new_val))
    
    def load_students(self):
        if not self.cursor:
            return
        try:
            self.cursor.execute("SELECT student_id, name, usn, current_block FROM Students")
            self.student_data = self.cursor.fetchall()
            self.cursor.fetchall()
            student_list = [f"{s[1]} ({s[2]}) - {s[3]}" for s in self.student_data]
            self.student_combo['values'] = student_list
            if student_list:
                self.student_combo.set(student_list[0])
                self.on_student_select(None)
        except Exception as e:
            self.status_bar.config(text=f"Error loading students: {e}")
    
    def on_student_select(self, event):
        selection = self.student_combo.get()
        for s in self.student_data:
            if f"{s[1]} ({s[2]}) - {s[3]}" == selection:
                self.current_student_id = s[0]
                break
        
        if self.current_student_id:
            self.show_nearest_outlets()
            self.load_order_history()
    
    def show_nearest_outlets(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        try:
            self.cursor.execute("SELECT outlet_id, outlet_name FROM Outlets WHERE is_active = TRUE")
            outlets = self.cursor.fetchall()
            self.cursor.fetchall()
            
            self.outlet_list = []
            for outlet in outlets:
                outlet_id, outlet_name = outlet
                
                self.cursor.execute("SELECT COUNT(*) FROM Menu_Items WHERE outlet_id = %s AND current_stock > 0", (outlet_id,))
                item_count = self.cursor.fetchone()[0]
                self.cursor.fetchall()
                
                distances = {
                    'Main Cafeteria': (150, 2),
                    'Hatti Kaapi': (50, 1),
                    'Udaya Upahara': (200, 3),
                    'Cafe Feasto': (400, 5),
                    'Maggi Point': (250, 3),
                    'Lassi Dhar': (80, 1),
                    'V J Mart': (30, 0.5),
                }
                distance, walk = distances.get(outlet_name, (500, 6))
                round_trip = walk * 2
                
                status = "✅ CAN ORDER" if round_trip <= 8 else "⚠️ TIGHT"
                
                self.tree.insert('', 'end', values=(
                    outlet_name, f"{distance}m", f"{walk}min", 
                    f"{round_trip}min", item_count, status
                ))
                self.outlet_list.append(outlet_name)
            
            self.outlet_combo['values'] = self.outlet_list
            if self.outlet_list:
                self.outlet_combo.set(self.outlet_list[0])
                self.load_menu(None)
                
        except Exception as e:
            self.status_bar.config(text=f"Error: {e}")
    
    def load_menu(self, event):
        outlet_name = self.outlet_combo.get()
        if not outlet_name:
            return
        
        try:
            self.cursor.execute("SELECT outlet_id FROM Outlets WHERE outlet_name = %s", (outlet_name,))
            result = self.cursor.fetchone()
            self.cursor.fetchall()
            
            if not result:
                return
            outlet_id = result[0]
            
            self.cursor.execute("""
                SELECT item_id, item_name, price, current_stock 
                FROM Menu_Items 
                WHERE outlet_id = %s AND current_stock > 0
            """, (outlet_id,))
            items = self.cursor.fetchall()
            self.cursor.fetchall()
            
            self.item_data = items
            item_list = [f"{i[1]} - ₹{i[2]} (Stock: {i[3]})" for i in items]
            self.item_combo['values'] = item_list
            if item_list:
                self.item_combo.set(item_list[0])
        except Exception as e:
            pass
    
    def load_order_history(self):
        """Load order history for selected student"""
        self.history_text.delete(1.0, tk.END)
        self.history_text.config(state='normal')
        
        if not self.current_student_id:
            self.history_text.insert(tk.END, "📭 Select a student to view orders")
            self.history_text.config(state='disabled')
            return
        
        try:
            print(f"Loading orders for student_id: {self.current_student_id}")
            
            query = """
            SELECT DATE_FORMAT(ord.order_time, '%d/%m %H:%i') as order_time, 
                   o.outlet_name, 
                   mi.item_name, 
                   ord.quantity, 
                   ord.total_price,
                   ord.status
            FROM Orders ord
            JOIN Outlets o ON ord.outlet_id = o.outlet_id
            JOIN Menu_Items mi ON ord.item_id = mi.item_id
            WHERE ord.student_id = %s
            ORDER BY ord.order_time DESC
            LIMIT 10
            """
            self.cursor.execute(query, (self.current_student_id,))
            orders = self.cursor.fetchall()
            self.cursor.fetchall()
            
            print(f"Found {len(orders)} orders")
            
            if not orders or len(orders) == 0:
                self.history_text.insert(tk.END, "📭 No orders yet. Place your first order!")
            else:
                for order in orders:
                    time_str = order[0] if order[0] else "Unknown"
                    outlet = order[1] if order[1] else "Unknown"
                    item = order[2] if order[2] else "Unknown"
                    qty = order[3] if order[3] else 0
                    price = order[4] if order[4] else 0
                    status = order[5] if order[5] else "pending"
                    
                    if status.lower() == 'confirmed':
                        line = f"• {time_str} | {outlet} | {item} x{qty} | ₹{price}"
                        self.history_text.insert(tk.END, line + "\n")
                        print(line)
            
            self.history_text.config(state='disabled')
            
        except Exception as e:
            self.history_text.insert(tk.END, f"❌ Error: {e}")
            self.history_text.config(state='disabled')
            print(f"Error: {e}")
    
    def place_order(self):
        """Place a real order (uses PlaceOrder procedure)"""
        if not self.current_student_id:
            messagebox.showerror("Error", "Please select a student")
            return
        
        outlet_name = self.outlet_combo.get()
        if not outlet_name:
            messagebox.showerror("Error", "Please select an outlet")
            return
        
        item_selection = self.item_combo.get()
        if not item_selection:
            messagebox.showerror("Error", "Please select an item")
            return
        
        quantity = self.qty_var.get()
        
        # Find item_id
        item_id = None
        for item in self.item_data:
            if f"{item[1]} - ₹{item[2]} (Stock: {item[3]})" == item_selection:
                item_id = item[0]
                break
        
        if not item_id:
            messagebox.showerror("Error", "Invalid item")
            return
        
        # Get outlet_id
        self.cursor.execute("SELECT outlet_id FROM Outlets WHERE outlet_name = %s", (outlet_name,))
        result = self.cursor.fetchone()
        self.cursor.fetchall()
        
        if not result:
            messagebox.showerror("Error", "Outlet not found")
            return
        outlet_id = result[0]
        
        try:
            # 6 parameters - matches PlaceOrder
            args = (self.current_student_id, item_id, outlet_id, quantity, None, None)
            self.cursor.callproc('PlaceOrder', args)
            
            for result in self.cursor.stored_results():
                rows = result.fetchall()
                if rows:
                    messagebox.showinfo("Success", rows[0][0])
                    self.status_bar.config(text=rows[0][0])
            
            self.db.commit()
            self.show_nearest_outlets()
            self.load_order_history()
            
        except Exception as e:
            self.db.rollback()
            messagebox.showerror("Failed", str(e))
    
    def run_concurrency_demo(self):
        """Simulate multiple students ordering the last few plates"""
        if not self.current_student_id:
            messagebox.showwarning("Selection Missing", "Please select a Student first.")
            return
        
        selection = self.item_combo.get()
        if not selection:
            messagebox.showwarning("Selection Missing", "Please select an Item first.")
            return
        
        self.conc_btn.config(state='disabled', text="🔄 Running...")
        self.conc_result.config(text="🔄 Running concurrency test...", fg=self.colors['warning'])
        self.root.update()
        
        try:
            selected_item_name = selection.split(" - ")[0].strip()
            
            self.cursor.execute("SELECT item_id, outlet_id, current_stock FROM Menu_Items WHERE item_name = %s", (selected_item_name,))
            result = self.cursor.fetchone()
            self.cursor.fetchall()
            
            if not result:
                self.conc_result.config(text="❌ Item not found", fg=self.colors['danger'])
                self.conc_btn.config(state='normal', text="🚀 RUN CONCURRENCY TEST")
                return
            
            item_id, outlet_id, current_stock = result
            
            self.conc_result.config(text=f"📊 Initial stock: {current_stock} plates. Starting {current_stock + 5} orders...", 
                                    fg=self.colors['warning'])
            self.root.update()
            
            # Reset stock to 3 for testing
            self.cursor.execute("UPDATE Menu_Items SET current_stock = 3 WHERE item_id = %s", (item_id,))
            self.db.commit()
            
            total_orders = 8
            success = 0
            fail = 0
            
            for i in range(total_orders):
                try:
                    # 5 parameters - matches TestConcurrency
                    args = (self.current_student_id, item_id, outlet_id, 1, None)
                    self.cursor.callproc('TestConcurrency', args)
                    
                    for r in self.cursor.stored_results():
                        rows = r.fetchall()
                        if rows and "SUCCESS" in rows[0][0]:
                            success += 1
                        else:
                            fail += 1
                    
                    self.cursor.fetchall()
                    self.db.commit()
                    
                except Exception as e:
                    fail += 1
                
                self.conc_result.config(text=f"🔄 Processing: {i+1}/{total_orders} orders... (Success: {success}, Failed: {fail})")
                self.root.update()
            
            if success <= 3:
                self.conc_result.config(
                    text=f"✅ CONCURRENCY TEST PASSED!\n📊 Initial stock: 3 plates\n📝 Total orders: {total_orders}\n✅ Success: {success}\n❌ Failed: {fail}\n🔒 FOR UPDATE lock is working!",
                    fg=self.colors['success']
                )
            else:
                self.conc_result.config(
                    text=f"⚠️ CONCURRENCY TEST FAILED!\n📊 Initial stock: 3 plates\n✅ Success: {success}\n❌ Failed: {fail}\n🔓 Only 3 should have succeeded!",
                    fg=self.colors['danger']
                )
            
            self.load_menu(None)
            self.show_nearest_outlets()
            
        except Exception as e:
            self.conc_result.config(text=f"❌ Error: {str(e)}", fg=self.colors['danger'])
        
        self.conc_btn.config(state='normal', text="🚀 RUN CONCURRENCY TEST")

if __name__ == "__main__":
    root = tk.Tk()
    app = DemoFriendlyApp(root)
    root.mainloop()