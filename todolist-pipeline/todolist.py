from flask import Flask, render_template_string, request, redirect, url_for
import sqlite3
from datetime import datetime

app = Flask(__name__)

# Create SQLite database and tasks table
def init_db():
    conn = sqlite3.connect('tasks.db')
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS tasks
        (id INTEGER PRIMARY KEY AUTOINCREMENT,
         title TEXT NOT NULL,
         created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
    ''')
    conn.commit()
    conn.close()

# HTML template (using template_string to keep everything in one file)
PAGE_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flask Task Manager</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .task {
            background-color: #f9f9f9;
            padding: 10px;
            margin: 5px 0;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .form-container {
            margin: 20px 0;
        }
        input[type="text"] {
            padding: 8px;
            width: 300px;
        }
        button {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .delete-btn {
            background-color: #f44336;
        }
    </style>
</head>
<body>
    <h1>Task Manager</h1>
    
    <div class="form-container">
        <form action="{{ url_for('add_task') }}" method="post">
            <input type="text" name="title" placeholder="Enter task" required>
            <button type="submit">Add Task</button>
        </form>
    </div>

    <div class="tasks-container">
        {% for task in tasks %}
        <div class="task">
            <span>{{ task[1] }}</span>
            <div>
                <small>{{ task[2] }}</small>
                <form action="{{ url_for('delete_task', task_id=task[0]) }}" method="post" style="display: inline;">
                    <button type="submit" class="delete-btn">Delete</button>
                </form>
            </div>
        </div>
        {% endfor %}
    </div>
</body>
</html>
'''

@app.route('/')
def index():
    conn = sqlite3.connect('tasks.db')
    c = conn.cursor()
    c.execute('SELECT * FROM tasks ORDER BY created_at DESC')
    tasks = c.fetchall()
    conn.close()
    return render_template_string(PAGE_TEMPLATE, tasks=tasks)

@app.route('/add', methods=['POST'])
def add_task():
    title = request.form.get('title')
    if title:
        conn = sqlite3.connect('tasks.db')
        c = conn.cursor()
        c.execute('INSERT INTO tasks (title) VALUES (?)', (title,))
        conn.commit()
        conn.close()
    return redirect(url_for('index'))

@app.route('/delete/<int:task_id>', methods=['POST'])
def delete_task(task_id):
    conn = sqlite3.connect('tasks.db')
    c = conn.cursor()
    c.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
    conn.commit()
    conn.close()
    return redirect(url_for('index'))

if __name__ == '__main__':
    init_db()
    app.run(debug=True)
#mytodolist