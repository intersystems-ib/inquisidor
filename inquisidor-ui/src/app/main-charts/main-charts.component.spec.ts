import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MainChartsComponent } from './main-charts.component';

describe('MainChartsComponent', () => {
  let component: MainChartsComponent;
  let fixture: ComponentFixture<MainChartsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MainChartsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MainChartsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
