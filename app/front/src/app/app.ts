import { Component, OnInit, signal } from '@angular/core';
import { HttpClient, provideHttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

interface Todo {
  id: number;
  title: string;
  done: boolean;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  todos = signal<Todo[]>([]);
  newTitle = '';

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.load();
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
    this.http.post<Todo>('/api/todos', { title }).subscribe({
      next: () => {
        this.newTitle = '';
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

  remove(todo: Todo): void {
    this.http.delete(`/api/todos/${todo.id}`).subscribe({
      next: () => this.load(),
      error: (err) => console.error('Erreur suppression todo', err),
    });
  }
}
