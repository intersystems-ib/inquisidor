import { Component, ViewChild, AfterViewInit, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { FormsModule } from '@angular/forms';
import { MatTableDataSource } from '@angular/material/table';
import { IrisService } from '../services/iris.service';

@Component({
  selector: 'app-main-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatInputModule,
    MatFormFieldModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatToolbarModule
  ],
  templateUrl: './main-list.component.html',
  styleUrl: './main-list.component.scss'
})
export class MainListComponent implements OnInit{

  columnas: string[] = ['titulo', 'contratante', 'fecha', 'ganador', 'importe', 'similitud'];
  loading = false;
  datos: Array<any> = [];
  dataSource = new MatTableDataSource(this.datos);

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(private irisService: IrisService) {
  
  }

  ngOnInit() {
    this.loading = true;
    this.filterList("");
  }

  applyFilter(event: KeyboardEvent): void {
    const filter = (event.target as HTMLInputElement).value;
    if (event.key == "Enter"){
      this.filterList(filter);
    }
  }

  filterList(filter: String) {
    const description = {
      "description": filter
    }
    this.irisService.getTenders(description).subscribe({
      next: res => {  
        this.datos = res;
        this.dataSource = new MatTableDataSource(this.datos);
        this.loading = false;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
      },
      error: err => {
        console.error(JSON.stringify(err));
      }
    });
  }
}
