import { Component, OnInit, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { DatePipe } from '@angular/common';

interface Todo {
  id: number;
  title: string;
  description: string;
  priority: 'basse' | 'normale' | 'haute';
  done: boolean;
  created_at: string;
  updated_at: string;
}

type Priority = 'basse' | 'normale' | 'haute';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FormsModule, DatePipe],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  todos = signal<Todo[]>([]);
  theme = signal<'light' | 'dark'>('light');

  // Formulaire d'ajout
  newTitle = '';
  newDescription = '';
  newPriority: Priority = 'normale';

  // Edition inline
  editingId = signal<number | null>(null);
  editTitle = '';
  editDescription = '';
  editPriority: Priority = 'normale';

  filter = signal<'toutes' | 'actives' | 'terminees'>('toutes');

  filteredTodos = computed(() => {
    const list = this.todos();
    const f = this.filter();
    if (f === 'actives') return list.filter((t) => !t.done);
    if (f === 'terminees') return list.filter((t) => t.done);
    return list;
  });

  remainingCount = computed(() => this.todos().filter((t) => !t.done).length);

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    const savedTheme = window.localStorage.getItem('lilou-theme');
    if (savedTheme === 'dark' || savedTheme === 'light') {
      this.theme.set(savedTheme);
    }
    this.applyTheme();
    this.load();
  }

  toggleTheme(): void {
    const next = this.theme() === 'light' ? 'dark' : 'light';
    this.theme.set(next);
    window.localStorage.setItem('lilou-theme', next);
    this.applyTheme();
  }

  private applyTheme(): void {
    document.documentElement.setAttribute('data-theme', this.theme());
  }

  load(): void {
    this.http.get<Todo[]>('/api/todos').subscribe({
      next: (data) => this.todos.set(data),
      error: (err) => console.error('Erreur chargement todos', err),
    });
  }

  add(): void {
    const title = this.newTitle.trim();
    if (!title) return;
    this.http
      .post<Todo>('/api/todos', {
        title,
        description: this.newDescription.trim(),
        priority: this.newPriority,
      })
      .subscribe({
        next: () => {
          this.newTitle = '';
          this.newDescription = '';
          this.newPriority = 'normale';
          this.load();
        },
        error: (err) => console.error('Erreur ajout todo', err),
      });
  }

  toggle(todo: Todo): void {
    this.http.patch(`/api/todos/${todo.id}`, { done: !todo.done }).subscribe({
      next: () => this.load(),
      error: (err) => console.error('Erreur maj todo', err),
    });
  }

  startEdit(todo: Todo): void {
    this.editingId.set(todo.id);
    this.editTitle = todo.title;
    this.editDescription = todo.description || '';
    this.editPriority = todo.priority;
  }

  cancelEdit(): void {
    this.editingId.set(null);
  }

  saveEdit(todo: Todo): void {
    const title = this.editTitle.trim();
    if (!title) return;
    this.http
      .put(`/api/todos/${todo.id}`, {
        title,
        description: this.editDescription.trim(),
        priority: this.editPriority,
      })
      .subscribe({
        next: () => {
          this.editingId.set(null);
          this.load();
        },
        error: (err) => console.error('Erreur edition todo', err),
      });
  }

  remove(todo: Todo): void {
    this.http.delete(`/api/todos/${todo.id}`).subscribe({
      next: () => this.load(),
      error: (err) => console.error('Erreur suppression todo', err),
    });
  }

  priorityLabel(p: Priority): string {
    return { basse: 'Basse', normale: 'Normale', haute: 'Haute' }[p];
  }
}
