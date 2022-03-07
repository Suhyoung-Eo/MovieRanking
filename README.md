# MovieRanking

## 프로젝트 설명

### 사용 API
- 영화진흥위원회(kofic): 박스오피스 순위 개봉일/ 누적 관람객 수
- 한국영화데이터베이스(KMDb): 영화 검색/ 섬네일 주소/ 영화 줄거리/ 장르/ 출연/ 제작 등 상세 정보

### 사용라이브러리
- Firebase

### 아키텍처 구조: MVVM 디자인 패턴 - [상세설명](https://github.com/Suhyoung-Eo/RxSwift_MVVM)
- 3개의 메인뷰와 여러 개의 서브뷰로 구성되어 있으나, 3개의 ViewModel이 메인뷰를 포함한 각 서브뷰들의 비즈니스 로직을 담당하고 있음

### 특징 
3줄기의 정보 흐름이 한줄기의 흐름처럼 보이도록 개발함

- 대부분의 함수는 비동기 처리되어 있으나 박스오피스 정보와 섬네일 주소 및 영화 상세정보가 kofic/ KMDb   
  두 곳을 통해 전달되므로 박스오피스 순위 정보 선취득 후 섬네일 주소/ 영화 상세정보는 스레드를 따로 생성,   
  동기 처리하여 박스오피스 순위와 일치시켜 한 서버에서 동작하는 것처럼 보이도록 함

- 평균평점/ 평가한 평점/ 코멘트/ 보고 싶은 영화 리스트/ 회원가입은 Firebase cloud 시스템 사용


### 구현내용 
- 박스오피스 정보/ 영화 정보 검색 - 서버로부터 취득

- 영화 평점 매기기/ 평가 점수가 반영된 평균평점 표시/ 보고 싶은 영화 저장/ 코멘트 관련 기능/ 회원가입/ 보고 싶어요 리스트/   
  평가한 영화 리스트/ 남긴 코멘트 리스트 - 해당 정보는 직접 Create/ Read/ Upadate/ Delete 하며 Firebase cloud에 저장

- 캐시메모리 활용: 한번 다운로드 된 이미지는 iOS에서 관리하는 캐시메모리에 저장하도록 개발, 캐시 키로 이미지 url이 사용됨.

### 구동화면

https://user-images.githubusercontent.com/91250216/155888498-08a51120-87ec-437a-a1dc-bdb8c91132c0.mp4
