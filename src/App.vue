<script setup>
import { ref, onMounted } from 'vue';

let features = ref([]);
let comments = ref([]);
let pagination = ref({});
let panel = ref(false);
let feature = ref({});
let page = ref(1);
let per_page = ref(25);
let type = ref("");

const getFeatures = async () => {
  try {
    features.value = [];
    const response = await fetch('http://localhost:3000/api/features?page=' + page.value + '&per_page=' + per_page.value + '&mag_type=' + type.value);
    const json = await response.json();

    setTimeout(() => {
      features.value = json.data;
      pagination.value = json.pagination;
    }, 1500);

  } catch (error) {
    console.error('Error', error);
  }
}

const getComments = async (feature) => {
  try {
    const response = await fetch('http://localhost:3000/api/features/' + feature.id + '/comments');
    const json = await response.json();
    comments.value = json.data.reverse();
  } catch (error) {
    console.error('Error', error);
  }
}

async function storeComment(feature) {
  try {
    let comment = document.getElementById("comment");
    const response = await fetch('http://localhost:3000/api/features/' + feature.id + '/comments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ body: comment.value })
    });

    comment.value = "";
    const responseData = await response.json();
    getComments(feature);
    return responseData;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

const setFeature = (f) => {
  panel.value = true;
  feature.value = f;
  getComments(f);
}

const closePanel = () => {
  panel.value = false;
  feature.value = {};
  comments.value = {};
}

const setPrev = () => {
  page.value -= 1;
  getFeatures();
}

const setNext = () => {
  page.value += 1;
  getFeatures();
}

const setPerPage = (evt) => {
  var value = evt.target.value;
  per_page.value = value;
  page.value = 1;
  getFeatures();
}

const setType = (evt) => {
  var value = evt.target.value;
  type.value = value;
  page.value = 1;
  getFeatures();
}

const thead = ['Date', 'Type', 'Magnitude', 'Place'];
const types = ['md', 'ml', 'ms', 'mw', 'me', 'mi', 'mb', 'mlg'];
const perpages = [25, 50, 100, 500, 1000];

onMounted(() => {
  getFeatures();
});
</script>

<template>
  <section>
    <div class="grid max-w-screen-xl px-4 py-8 mx-auto lg:gap-8 xl:gap-0 lg:py-16 lg:grid-cols-12">
      <div class="mr-auto place-self-center lg:col-span-7">
        <h1
          class="max-w-2xl mb-4 text-4xl font-extrabold tracking-tight leading-none md:text-5xl xl:text-6xl dark:text-white">
          World earthquakes in the last 30 days</h1>
        <p class="max-w-2xl mb-6 font-light text-gray-500 lg:mb-8 md:text-lg lg:text-xl dark:text-gray-400">USGS All
          earthquakes in the last 30 days. Simplifying the earthquake stack.</p>
      </div>
      <div class="hidden lg:mt-0 lg:col-span-5 lg:flex">
        <img src="/earth.gif" alt="mockup" class="rounded-full">
      </div>
    </div>
  </section>

  <section class="bg-gray-50 dark:bg-gray-900 p-3 sm:p-5">
    <div class="mx-auto max-w-screen-xl px-4 lg:px-12">
      <!-- Start coding here -->
      <div class="bg-white dark:bg-gray-800 relative shadow-md sm:rounded-lg overflow-hidden">
        <div class="flex flex-col md:flex-row items-center justify-between space-y-3 md:space-y-0 md:space-x-4 p-4">
          <div class="w-full md:w-1/2"></div>
          <div
            class="w-full md:w-auto flex flex-col md:flex-row space-y-2 md:space-y-0 items-stretch md:items-center justify-end md:space-x-3 flex-shrink-0">

            <select @change="setType"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
              <option value="">Any type</option>
              <option v-for="(item, index) in types" :key="index" :value="item">{{ item.toUpperCase() }}</option>
            </select>


            <select @change="setPerPage"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
              <option v-for="(item, index) in perpages" :key="index" :value="item">{{ item }} Per Page</option>
            </select>
            <button type="button" @click="getFeatures"
              class="flex items-center justify-center text-white bg-gray-700 hover:bg-primary-800 focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-gray-600 dark:hover:bg-gray-700 focus:outline-none dark:focus:ring-gray-800">
              Refresh
            </button>
          </div>


        </div>

        <div class="overflow-x-auto">
          <div v-if="features.length === 0" class="text-lg text-gray-800 text-center mb-12">
            <span>No results</span>
          </div>
          <table v-else class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
              <tr>
                <th scope="col" class="px-4 py-3" v-for="h in thead" :key="h.id">{{ h }}</th>
                <th scope="col" class="px-4 py-3">
                  <span class="sr-only">Actions</span>
                </th>
              </tr>

            </thead>
            <tbody>
              <tr class="border-b dark:border-gray-700" v-for="f in features" :key="f.id">
                <th scope="row" class="px-4 py-3 font-medium text-gray-900 whitespace-nowrap dark:text-white"> {{
                  f.attributes.time }}</th>
                <td class="px-4 py-3">{{ f.attributes.mag_type.toUpperCase() }}</td>
                <td class="px-4 py-3">{{ f.attributes.magnitude }}</td>
                <td class="px-4 py-3">{{ f.attributes.place }}</td>

                <td class="px-4 py-3 flex items-center justify-end">
                  <button type="button" @click="setFeature(f)"
                    class="flex items-center justify-center text-white bg-gray-400 hover:bg-primary-800 focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-gray-600 dark:hover:bg-gray-700 focus:outline-none dark:focus:ring-gray-800">
                    Show
                  </button>
                </td>
              </tr>

            </tbody>
          </table>
        </div>
        <nav v-if="pagination.total"
          class="flex flex-col md:flex-row justify-between items-start md:items-center space-y-3 md:space-y-0 p-4"
          aria-label="Table navigation">

          <span class="text-sm font-normal text-gray-500">
            Showing page
            <span class="font-semibold text-gray-900">{{ pagination.current_page }}</span>
            of
            <span class="font-semibold text-gray-900">{{ pagination.total > 0 ? Math.ceil(pagination.total /
              pagination.per_page) : 0 }}</span>
          </span>

          <ul class="inline-flex items-stretch -space-x-px">
            <li>
              <button @click="setPrev()" :disabled="pagination.current_page === 1"
                class="flex items-center justify-center h-full py-1.5 px-3 ml-0 text-gray-500 bg-white rounded-l-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white">

                <svg class="w-5 h-5" aria-hidden="true" fill="currentColor" viewbox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd"
                    d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                    clip-rule="evenodd" />
                </svg>
                <span>Prev</span>
              </button>
            </li>
            <li>
              <button @click="setNext()"
                :disabled="pagination.current_page === Math.ceil(pagination.total / pagination.per_page)"
                class="flex items-center justify-center h-full py-1.5 px-3 leading-tight text-gray-500 bg-white rounded-r-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white">
                <span>Next</span>
                <svg class="w-5 h-5" aria-hidden="true" fill="currentColor" viewbox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd"
                    d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                    clip-rule="evenodd" />
                </svg>
              </button>
            </li>
          </ul>
        </nav>

        <div class="relative z-10" aria-labelledby="slide-over-title" role="dialog" :aria-modal="panel" v-show="panel">
          <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

          <div class="fixed inset-0 overflow-hidden">
            <div class="absolute inset-0 overflow-hidden">
              <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">

                <div class="pointer-events-auto relative w-screen max-w-md">

                  <div class="absolute left-0 top-0 -ml-8 flex pr-2 pt-4 sm:-ml-10 sm:pr-4">
                    <button type="button" @click="closePanel"
                      class="relative rounded-md text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white">
                      <span class="absolute -inset-2.5"></span>
                      <span class="sr-only">Close panel</span>
                      <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                        aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>

                  <div class="flex h-full flex-col overflow-y-scroll bg-white py-6 shadow-xl" v-if="feature.attributes">

                    <div class="p-8 sm:p-10 lg:flex-auto">
                      <h3 class="text-2xl font-bold tracking-tight text-gray-900">{{ feature.attributes.title }}</h3>
                      <p class="text-sm font-semibold leading-6 tracking-wide text-gray-600">{{ feature.attributes.time
                        }}
                      </p>
                      <div class="mt-4 flex items-center gap-x-4">
                        <div class="h-px flex-auto bg-gray-100"></div>
                      </div>
                      <ul role="list"
                        class="mt-8 grid grid-cols-1 gap-4 text-sm leading-3 text-gray-600 sm:grid-cols-2 sm:gap-6">
                        <li class="flex gap-x-3">
                          ID: {{ feature.attributes.external_id.toUpperCase() }}
                        </li>
                        <li class="flex gap-x-3">
                          Mag Type: {{ feature.attributes.mag_type.toUpperCase() }}
                        </li>
                        <li class="flex gap-x-3">
                          Latitude: {{ feature.attributes.coordinates.latitude }}
                        </li>
                        <li class="flex gap-x-3">
                          Longitude: {{ feature.attributes.coordinates.longitude }}
                        </li>
                      </ul>

                      <div class="mt-4 p-1 lg:w-full lg:max-w-md lg:flex-shrink-0">
                        <div :class="feature.attributes.tsunami ? 'bg-red-100' : 'bg-green-100'"
                          class="rounded-2xl py-4 text-center ring-1 ring-inset ring-gray-900/5 lg:flex lg:flex-col lg:justify-center">
                          <div class="mx-auto max-w-xs">
                            <p class="text-base font-semibold text-gray-600">{{ feature.attributes.tsunami ? 'Has a' :
                              'There is no' }} tsunami warning</p>
                            <p class="mt-4 flex items-baseline justify-center gap-x-2">
                              <span class="text-5xl font-bold tracking-tight text-gray-900">{{
                                feature.attributes.magnitude }}</span>
                              <span class="text-sm font-semibold leading-6 tracking-wide text-gray-600">Richter
                                scale</span>
                            </p>

                            <a :href="feature.links.external_url" target="_blank"
                              class="mt-4 block w-full rounded-md bg-gray-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-gray-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-600">See
                              details</a>
                            <p class="mt-2 text-xs leading-5 text-gray-600">You will be redirected to the site
                              earthquake.usgs.gov</p>

                          </div>
                        </div>
                      </div>

                      <section class="bg-white">
                        <div class="max-w-2xl mx-auto px-4">
                          <div class="flex justify-between items-center my-6">
                            <h2 class="text-lg lg:text-2xl font-medium text-gray-900 dark:text-white">Comments
                              ({{ comments.length }})</h2>
                          </div>
                          <form class="mb-6" @submit.prevent="storeComment(feature)">
                            <div
                              class="py-2 px-4 mb-4 bg-white rounded-lg rounded-t-lg border border-gray-200 dark:bg-gray-800 dark:border-gray-700">
                              <label for="comment" class="sr-only">Your comment</label>
                              <textarea id="comment" rows="4"
                                class="px-0 w-full text-sm text-gray-900 border-0 focus:ring-0 focus:outline-none dark:text-white dark:placeholder-gray-400 dark:bg-gray-800"
                                placeholder="Write a comment..." required></textarea>
                            </div>
                            <button type="submit"
                              class="inline-flex items-center py-2.5 px-4 text-xs font-medium text-center text-white bg-blue-700 rounded-lg focus:ring-4 focus:ring-blue-200 hover:bg-blue-800">
                              Post
                            </button>
                          </form>

                          <article
                            class="p-6 mb-3 text-base bg-white border-t border-gray-200 dark:border-gray-700 dark:bg-gray-900"
                            v-for="cc in comments" :key="cc.id">
                            <footer class="flex justify-between items-center mb-2">
                              <div class="flex items-center">
                                <p class="text-xs text-gray-600 dark:text-gray-400">{{ cc.created_at }}</p>
                              </div>
                            </footer>
                            <p class="text-gray-500 dark:text-gray-400">{{ cc.body }}</p>
                          </article>

                        </div>
                      </section>
                    </div>


                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>
