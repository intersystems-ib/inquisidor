import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MainPublishedComponent } from './main-published.component';

describe('MainPublishedComponent', () => {
  let component: MainPublishedComponent;
  let fixture: ComponentFixture<MainPublishedComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MainPublishedComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MainPublishedComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
