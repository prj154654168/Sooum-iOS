        reactor.state.map(\.mustUpdate)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                
                let exitAction = SOMDialogAction(
                    title: Text.exitActionTitle,
                    style: .gray,
                    action: {
                        // 앱 종료
                        // 자연스럽게 종료하기 위해 종료전, suspend 상태로 변경 후 종료
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                )
                let updateAction = SOMDialogAction(
                    title: Text.updateActionTitle,
                    style: .primary,
                    action: {
                        #if DEVELOP
                        // 개발 버전일 때 testFlight로 전환
                        let strUrl = "\(Text.testFlightStrUrl)/\(Info.appId)"
                        if let testFlightUrl = URL(string: strUrl) {
                            UIApplication.shared.open(testFlightUrl, options: [:], completionHandler: nil)
                        }
                        #elseif PRODUCTION
                        // 운영 버전일 때 app store로 전환
                        let strUrl = "\(Text.appStoreStrUrl)\(Info.appId)"
                        if let appStoreUrl = URL(string: strUrl) {
                            UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                        }
                        #endif

                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.updateVerionTitle,
                    message: Text.updateVersionMessage,
                    actions: [exitAction, updateAction]
                )
            }
            .disposed(by: self.disposeBag)
