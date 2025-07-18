import { inject } from '@angular/core';
import {
  HttpInterceptorFn,
  HttpRequest,
  HttpHandlerFn,
} from '@angular/common/http';
import { StorageService } from '../services/storage.service';
import { Router } from '@angular/router';
import { tap } from 'rxjs/operators';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const storageService = inject(StorageService);

  return next(req).pipe(
    // Captura errores de la respuesta
    tap({
      error: (error) => {
        if (error.status === 401) {
          storageService.clean();
          router.navigate(['login']);
        } else if (error.status === 403) {
          storageService.clean();
          router.navigate(['login']);
        }
      }
    })
  );
};