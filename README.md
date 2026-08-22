# VitraX Mobile

Flutter companion app for **VitraX** — a glass factory production management system.
Talks to [`VitraX.API`](../VitraX.API) over JWT-authenticated REST endpoints and mirrors
the visual identity of [`VitraX.MVC`](../VitraX.MVC) (teal/navy palette, Cairo font).

## Stack

- Flutter 3.x, Provider for state management
- `http` for the API client, `shared_preferences` for persisting the JWT token
- Custom bundled Cairo variable font (`assets/fonts/Cairo-Variable.ttf`)

## Screens

- **Login / Register** — JWT auth against `POST /api/Auth/login` and `/register`
- **Dashboard** (main page) — KPI counts + recent production orders
- **Orders / Workers / Tasks** (the three other pages) — list views reading from
  `VitraX.API`, with `showModalBottomSheet` used both for record details and for
  quick-add forms (the SheetModal requirement)

Navigation shell (`lib/screens/shell_screen.dart`) provides one consistent
`AppBar` + `Drawer` + `BottomNavigationBar` across all four pages.

## Running locally

```
flutter pub get
flutter run --dart-define=VX_API_BASE_URL=http://10.0.2.2:5186   # Android emulator
```

`VX_API_BASE_URL` defaults to `10.0.2.2:5186` on Android emulators and `localhost:5186`
elsewhere; override it to point at a LAN IP for a physical device (see `lib/services/api_client.dart`).

## Documentation

Full project documentation (installation, user manual, testing, conclusion, references)
covering all three VitraX projects lives in
[`VitraX.API/DOCUMENTATION.md`](https://github.com/9nr9gtg62x-lgtm/VitraX.API/blob/master/DOCUMENTATION.md).
