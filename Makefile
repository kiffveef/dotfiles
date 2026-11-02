# dotfiles の入口。処理の中身は scripts/ のシェルスクリプトにあり、ここは順序とメニューだけを持つ。
# 前提: scripts/prerequisites.sh で git と build-essential (make) が入っていること。

SHELL   := /bin/bash
SCRIPTS := scripts

.DEFAULT_GOAL := help
.NOTPARALLEL:
.PHONY: help bootstrap deploy apt rust mise plugins docker update

help: ## このヘルプを表示
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*## "} {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

# 個々のターゲットは自分の処理だけを行い、依存関係は bootstrap の並び順で表す。
# (ターゲット間に依存を書くと、make mise のたびに apt や rust まで走って遅いため)
bootstrap: deploy apt rust mise plugins ## 一括セットアップ (docker は含まない)
	@echo "bootstrap 完了。exec zsh でシェルを読み直す"

deploy: ## 設定ファイルを配置 (symlink + テンプレート)
	@$(SCRIPTS)/deploy.sh

apt: ## apt パッケージ
	@$(SCRIPTS)/bootstrap.sh apt

rust: ## rustup + cargo ツール (要: apt)
	@$(SCRIPTS)/bootstrap.sh rust

mise: ## mise + ランタイム (要: apt, deploy)
	@$(SCRIPTS)/bootstrap.sh mise

plugins: ## sheldon プラグイン (要: rust, deploy)
	@$(SCRIPTS)/bootstrap.sh plugins

docker: ## Docker Engine (要: apt)
	@$(SCRIPTS)/bootstrap.sh docker

update: ## インストール済みのもの全部を更新
	@$(SCRIPTS)/bootstrap.sh update
