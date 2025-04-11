import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

const IRIS_API = 'api/inquisidor/';

let httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Injectable({
  providedIn: 'root'
})
export class IrisService {

  constructor(private http: HttpClient) { }

  getTenders(description: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'getTenders', description, httpOptions
    )
  }

  getWinners(filter: String): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getWinners?filter='+filter, httpOptions
    )
  }

  getYears(): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getYears', httpOptions
    )
  }

}
