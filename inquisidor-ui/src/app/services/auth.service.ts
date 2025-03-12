import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

const AUTH_API = 'api/inquisidor/';

let httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  public tokenValue: string;
  
  constructor(private http: HttpClient) {
    this.tokenValue = "";
  }

  login(username: string, password: string): Observable<any> {
    return this.http.post<Response>(
      AUTH_API + 'login',
      {
        "user": username,
        "password": password,
      },
      httpOptions
    )
  }

  logout(): Observable<any> {
    return this.http.post(AUTH_API + 'logout', { }, httpOptions);
  }

}
