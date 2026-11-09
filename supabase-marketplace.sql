create table if not exists public.walker_profiles (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  display_name text not null,
  area text not null default '',
  bio text not null default '',
  price_mxn integer check (price_mxn is null or price_mxn > 0),
  photo_path text,
  sizes text[] not null default '{}',
  preferences text[] not null default '{}',
  availability text[] not null default '{}',
  availability_days smallint[] not null default '{}',
  is_available boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.walker_profiles enable row level security;
revoke all on public.walker_profiles from anon, authenticated;
grant select on public.walker_profiles to authenticated;
grant insert (user_id, display_name, area, bio, price_mxn, photo_path, sizes, preferences, availability, availability_days, is_available, updated_at)
  on public.walker_profiles to authenticated;
grant update (display_name, area, bio, price_mxn, photo_path, sizes, preferences, availability, availability_days, is_available, updated_at)
  on public.walker_profiles to authenticated;

drop policy if exists "Anyone can view walker listings" on public.walker_profiles;
create policy "Authenticated users can view walker listings"
  on public.walker_profiles for select
  to authenticated
  using (true);

revoke select on public.profiles from anon;
drop policy if exists "Public can read walker profiles" on public.profiles;

drop policy if exists "Walkers and admins can create walker listings" on public.walker_profiles;
create policy "Walkers and admins can create walker listings"
  on public.walker_profiles for insert
  to authenticated
  with check (
    (user_id = auth.uid() and exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
    ))
    or exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "Walkers and admins can update walker listings" on public.walker_profiles;
create policy "Walkers and admins can update walker listings"
  on public.walker_profiles for update
  to authenticated
  using (
    (user_id = auth.uid() and exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
    ))
    or exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
    )
  )
  with check (
    (user_id = auth.uid() and exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
    ))
    or exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
    )
  );

create or replace function public.ensure_walker_listing()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.role = 'walker' then
    insert into public.walker_profiles (user_id, display_name)
    values (new.id, new.full_name)
    on conflict (user_id) do update
      set display_name = excluded.display_name;
  end if;
  return new;
end;
$$;

drop trigger if exists ensure_walker_listing_after_profile_change on public.profiles;
create trigger ensure_walker_listing_after_profile_change
  after insert or update of role, full_name on public.profiles
  for each row execute function public.ensure_walker_listing();

insert into public.walker_profiles (user_id, display_name)
select p.id, p.full_name
from public.profiles p
where p.role = 'walker'
on conflict (user_id) do update
  set display_name = excluded.display_name;

create table if not exists public.customer_dogs (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 40),
  count smallint not null default 1 check (count between 1 and 10),
  breed text not null check (char_length(breed) between 1 and 50),
  size text not null check (size in ('Pequeño', 'Mediano', 'Grande')),
  behavior text not null check (char_length(behavior) between 1 and 500),
  photo_path text,
  created_at timestamptz not null default now()
);

alter table public.customer_dogs enable row level security;
revoke all on public.customer_dogs from anon, authenticated;
grant select, insert, update, delete on public.customer_dogs to authenticated;

drop policy if exists "Customers manage their dogs" on public.customer_dogs;
create policy "Customers manage their dogs"
  on public.customer_dogs for all
  to authenticated
  using (
    customer_id = auth.uid()
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'customer')
  )
  with check (
    customer_id = auth.uid()
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'customer')
  );

create table if not exists public.walk_bookings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles (id) on delete cascade,
  walker_id uuid not null references public.profiles (id) on delete cascade,
  dog_id uuid not null references public.customer_dogs (id) on delete restrict,
  customer_name text not null,
  dog_name text not null,
  dog_count smallint not null check (dog_count between 1 and 10),
  dog_breed text not null,
  dog_size text not null check (dog_size in ('Pequeño', 'Mediano', 'Grande')),
  dog_behavior text not null,
  dog_photo_path text,
  walk_date date not null,
  walk_time time without time zone not null,
  address text not null check (char_length(address) between 1 and 250),
  phone text not null check (char_length(phone) between 7 and 30),
  price_mxn integer not null check (price_mxn > 0),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'rejected', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

alter table public.walk_bookings enable row level security;
revoke all on public.walk_bookings from anon, authenticated;
grant select, insert on public.walk_bookings to authenticated;
grant update (status) on public.walk_bookings to authenticated;

drop policy if exists "Customers and assigned walkers can view bookings" on public.walk_bookings;
create policy "Customers and assigned walkers can view bookings"
  on public.walk_bookings for select
  to authenticated
  using (
    customer_id = auth.uid()
    or (walker_id = auth.uid() and exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
    ))
    or exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "Customers can request available walks" on public.walk_bookings;
create policy "Customers can request available walks"
  on public.walk_bookings for insert
  to authenticated
  with check (
    customer_id = auth.uid()
    and status = 'pending'
    and walk_date >= current_date
    and exists (
      select 1 from public.profiles p where p.id = auth.uid() and p.role = 'customer'
    )
    and exists (
      select 1 from public.customer_dogs d
      where d.id = dog_id
        and d.customer_id = auth.uid()
        and d.name = dog_name
        and d.count = dog_count
        and d.breed = dog_breed
        and d.size = dog_size
        and d.behavior = dog_behavior
        and d.photo_path is not distinct from dog_photo_path
    )
    and exists (
      select 1
      from public.walker_profiles w
      where w.user_id = walker_id
        and w.is_available
        and w.price_mxn = walk_bookings.price_mxn
        and w.availability @> array[to_char(walk_time, 'HH24:MI')]
        and w.availability_days @> array[extract(dow from walk_date)::smallint]
        and (cardinality(w.sizes) = 0 or w.sizes @> array[dog_size])
        and exists (
          select 1 from public.profiles p where p.id = w.user_id and p.role = 'walker'
        )
    )
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.full_name = customer_name
    )
  );

drop policy if exists "Assigned walkers can respond to pending bookings" on public.walk_bookings;
create policy "Assigned walkers can respond to pending bookings"
  on public.walk_bookings for update
  to authenticated
  using (
    status = 'pending'
    and (
      (walker_id = auth.uid() and exists (
        select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
      ))
      or exists (
        select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
      )
    )
  )
  with check (
    status in ('confirmed', 'rejected')
    and (
      (walker_id = auth.uid() and exists (
        select 1 from public.profiles p where p.id = auth.uid() and p.role = 'walker'
      ))
      or exists (
        select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
      )
    )
  );

create unique index if not exists walk_bookings_reserved_slot
  on public.walk_bookings (walker_id, walk_date, walk_time)
  where status in ('pending', 'confirmed');
create index if not exists walk_bookings_customer_created
  on public.walk_bookings (customer_id, created_at desc);
create index if not exists walk_bookings_walker_date
  on public.walk_bookings (walker_id, walk_date, walk_time);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('walker-photos', 'walker-photos', false, 2097152, array['image/jpeg']),
  ('pet-photos', 'pet-photos', false, 2097152, array['image/jpeg'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public can view walker photos" on storage.objects;
create policy "Authenticated users can view walker photos"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'walker-photos');

drop policy if exists "Walkers and admins manage their profile photos" on storage.objects;
create policy "Walkers and admins manage their profile photos"
  on storage.objects for all
  to authenticated
  using (
    bucket_id = 'walker-photos'
    and exists (
      select 1 from public.profiles p
      where p.id::text = (storage.foldername(name))[1]
        and (p.id = auth.uid() or exists (
          select 1 from public.profiles admin where admin.id = auth.uid() and admin.role = 'admin'
        ))
    )
  )
  with check (
    bucket_id = 'walker-photos'
    and exists (
      select 1 from public.profiles p
      where p.id::text = (storage.foldername(name))[1]
        and (p.id = auth.uid() or exists (
          select 1 from public.profiles admin where admin.id = auth.uid() and admin.role = 'admin'
        ))
    )
  );

drop policy if exists "Customers manage their pet photos" on storage.objects;
create policy "Customers manage their pet photos"
  on storage.objects for all
  to authenticated
  using (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Walkers can view pet photos shared with their bookings" on storage.objects;
create policy "Walkers can view pet photos shared with their bookings"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'pet-photos'
    and exists (
      select 1
      from public.walk_bookings b
      where b.walker_id = auth.uid()
        and b.dog_photo_path = name
        and b.status in ('pending', 'confirmed', 'rejected', 'completed')
    )
  );
