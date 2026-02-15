import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { concat } from "@ember/string";
import { eq } from "truth-helpers";
import HorizontalOverflowNav from "discourse/components/horizontal-overflow-nav";
import categoryLink from "discourse/helpers/category-link";

export default class CustomCategoriesNavbar extends Component {
  @service site;
  @service router;

  @tracked activeSlug = "";
  @tracked activePage = "";

  constructor() {
    super(...arguments);
    this.setActiveSlug();
    this.setActivePage();
    this.router.on("routeDidChange", this, this.setActiveSlug);
    this.router.on("routeDidChange", this, this.setActivePage);

    // eslint-disable-next-line no-console
    console.log(settings.links);
  }

  get shouldRender() {
    const isChat = this.router.currentRouteName.startsWith("chat");
    const isMinimized = this.args.outletArgs.minimized;
    const alwaysHideDocked = settings.hide_on_topic_scroll
      ? isMinimized
      : this.site.mobileView && isMinimized;

    return !alwaysHideDocked && !isChat;
  }

  setActivePage() {
    const currentRoute = this.router.currentRoute;
    if (currentRoute && !currentRoute.attributes?.category) {
      this.activePage = this.router.currentURL;

      // scroll active link into view
      document
        .querySelector(`a[href="${this.activePage}"]`)
        ?.scrollIntoView({
          block: "nearest",
          inline: "center",
        });
    }
  }

  setActiveSlug() {
    const currentRoute = this.router.currentRoute;

    if (currentRoute && currentRoute.attributes?.category) {
      let activeCategory = currentRoute.attributes.category;

      while (activeCategory.parentCategory) {
        activeCategory = activeCategory.parentCategory;
      }

      this.activeSlug = activeCategory.slug;

      // scroll active category into view
      document
        .querySelector(`a[href*="/c/${this.activeSlug}"]`)
        ?.scrollIntoView({
          block: "nearest",
          inline: "center",
        });
    }
  }

  <template>
    {{#if this.shouldRender}}
      <div class="wrap custom-categories-navbar">
        <HorizontalOverflowNav>
          {{#each settings.links as |route|}}
            <li>
              <a href={{route.link}} class={{if (eq this.activePage route.link) "active" ""}}>{{route.label}}</a>
            </li>
          {{/each}}

          {{#each this.site.categories as |sc|}}
            {{#unless sc.parentCategory}}
              <li>
                {{categoryLink
                  sc
                  extraClasses=(if (eq this.activeSlug sc.slug) "active")
                }}
              </li>
            {{/unless}}
          {{/each}}
        </HorizontalOverflowNav>
      </div>
    {{/if}}
  </template>
}
