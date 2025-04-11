import { Injectable } from '@angular/core';

const USER_KEY = 'inquisidor-auth-user';
const EXPIRATION_KEY = 'inquisidor-auth-expiration';

@Injectable({
  providedIn: 'root'
})
export class StorageService {

  constructor() { }

  clean(): void {
    window.sessionStorage.removeItem(USER_KEY);
  }

  save(userToken: string, expire: number): void {
    window.sessionStorage.setItem(USER_KEY, userToken);
    window.sessionStorage.setItem(EXPIRATION_KEY, (expire*1000).toString());
  }
  
  public isLoggedIn(): boolean {
    const user = window.sessionStorage.getItem(USER_KEY);
    const expiration = window.sessionStorage.getItem(EXPIRATION_KEY);
    const currentTime = new Date();

    if (user && Number(expiration) > currentTime.getTime()) {
      return true;
    }

    return false;
  }

  public getToken(): string {
    const user = window.sessionStorage.getItem(USER_KEY);
    const expiration = window.sessionStorage.getItem(EXPIRATION_KEY);
    const currentTime = new Date();

    if (user && Number(expiration) > currentTime.getTime()) {
      return user;
    }
    else {
      return "";
    }
  }
}
